import SwiftUI
import MapLibre
import CoreLocation

struct MapView: UIViewRepresentable {
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    let answerCoordinate: CLLocationCoordinate2D?

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIView(context: Context) -> MLNMapView {
        let map = MLNMapView(frame: .zero,
                             styleURL: URL(string: "https://tiles.openfreemap.org/styles/liberty"))
        map.delegate = context.coordinator
        map.setCenter(CLLocationCoordinate2D(latitude: 18, longitude: 0), zoomLevel: 1.2, animated: false)
        map.logoView.isHidden = true
        map.attributionButton.tintColor = .secondaryLabel
        map.minimumZoomLevel = 0.5
        map.maximumZoomLevel = 16.0
        map.isScrollEnabled  = true
        map.isZoomEnabled    = true
        map.isPitchEnabled   = false
        map.isRotateEnabled  = false
        let tap = UITapGestureRecognizer(target: context.coordinator,
                                         action: #selector(Coordinator.didTap(_:)))
        map.addGestureRecognizer(tap)
        context.coordinator.mapView = map
        return map
    }

    func updateUIView(_ map: MLNMapView, context: Context) {
        let c = context.coordinator

        // Show country names only after the player places a guess.
        c.setCountryLabels(visible: selectedCoordinate != nil, on: map)

        // — Annotations —
        map.removeAnnotations(map.annotations ?? [])
        var pins: [MLNAnnotation] = []
        if let sel = selectedCoordinate {
            let p = MLNPointAnnotation(); p.coordinate = sel; p.title = "Your guess"
            pins.append(p)
        }
        if let ans = answerCoordinate {
            let p = MLNPointAnnotation(); p.coordinate = ans; p.title = "Answer"
            pins.append(p)
        }
        if !pins.isEmpty { map.addAnnotations(pins) }

        let selChanged  = !Self.coordEqual(selectedCoordinate, c.lastSelectedCoord)
        let ansAppeared = answerCoordinate != nil && c.lastAnswerCoord == nil

        c.lastSelectedCoord = selectedCoordinate
        c.lastAnswerCoord   = answerCoordinate

        // — Zoom & highlight —
        if let ans = answerCoordinate, let sel = selectedCoordinate, ansAppeared {
            // Answer revealed: fit both pins, stop pulsing
            let latPad = max(abs(ans.latitude  - sel.latitude)  * 0.7, 6.0)
            let lonPad = max(abs(ans.longitude - sel.longitude) * 0.7, 6.0)
            let bounds = MLNCoordinateBounds(
                sw: CLLocationCoordinate2D(latitude:  min(ans.latitude,  sel.latitude)  - latPad,
                                           longitude: min(ans.longitude, sel.longitude) - lonPad),
                ne: CLLocationCoordinate2D(latitude:  max(ans.latitude,  sel.latitude)  + latPad,
                                           longitude: max(ans.longitude, sel.longitude) + lonPad)
            )
            map.setVisibleCoordinateBounds(
                bounds,
                edgePadding: UIEdgeInsets(top: 80, left: 40, bottom: 300, right: 40),
                animated: true
            )
            c.stopPulsing()

        } else if let sel = selectedCoordinate, selChanged, answerCoordinate == nil {
            // New pin: zoom in and pulse the country border
            map.setCenter(sel, zoomLevel: max(map.zoomLevel, 3.5), animated: true)
            c.updateHighlight(for: sel, on: map)

        } else if selectedCoordinate == nil && selChanged {
            // Pin cleared
            c.clearHighlight(on: map)
        }
    }

    private static func coordEqual(_ a: CLLocationCoordinate2D?, _ b: CLLocationCoordinate2D?) -> Bool {
        guard let a, let b else { return a == nil && b == nil }
        return a.latitude == b.latitude && a.longitude == b.longitude
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, MLNMapViewDelegate {
        var parent: MapView
        weak var mapView: MLNMapView?

        // Change-tracking (avoids redundant map operations on re-renders)
        var lastSelectedCoord: CLLocationCoordinate2D?
        var lastAnswerCoord:   CLLocationCoordinate2D?

        private let countryIndex = CountryIndex()
        private var pulseTimer: Timer?
        private var pulsePhase: Double = 0

        // Layer identifiers
        private let srcID  = "hu-countries"
        private let fillID = "hu-country-fill"
        private let lineID = "hu-country-line"
        private var countryLabelLayerIDs: [String] = []

        private lazy var goldPinImage: UIImage? = {
            guard let raw = UIImage(named: "GoldPin") else { return nil }
            let targetHeight: CGFloat = 40
            let scale = targetHeight / raw.size.height
            let size = CGSize(width: raw.size.width * scale, height: targetHeight)
            return UIGraphicsImageRenderer(size: size).image { _ in
                raw.draw(in: CGRect(origin: .zero, size: size))
            }
        }()

        private final class GoldPinAnnotationView: MLNAnnotationView {
            init(reuseIdentifier: String, image: UIImage) {
                super.init(reuseIdentifier: reuseIdentifier)
                frame = CGRect(origin: .zero, size: image.size)
                let imageView = UIImageView(image: image)
                imageView.frame = bounds
                imageView.contentMode = .scaleAspectFit
                addSubview(imageView)

                // Keep the pin tip (bottom-center) on the tapped coordinate.
                centerOffset = CGVector(dx: 0, dy: -(image.size.height / 2))
            }

            @available(*, unavailable)
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }

        init(parent: MapView) { self.parent = parent }

        @objc func didTap(_ g: UITapGestureRecognizer) {
            guard let map = mapView else { return }
            parent.selectedCoordinate = map.convert(g.location(in: map), toCoordinateFrom: map)
        }

        // MARK: MLNMapViewDelegate

        func mapView(_ mapView: MLNMapView, viewFor annotation: MLNAnnotation) -> MLNAnnotationView? {
            guard annotation.title == "Your guess" else { return nil } // keep default red pin for answer
            let reuseID = "gold-pin-view"
            if let existing = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? GoldPinAnnotationView {
                return existing
            }
            guard let image = goldPinImage else { return nil }
            return GoldPinAnnotationView(reuseIdentifier: reuseID, image: image)
        }

        func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
            // Remove all default boundary / admin boundary line layers
            style.layers
                .filter {
                    $0.identifier.localizedCaseInsensitiveContains("boundary") ||
                    $0.identifier.localizedCaseInsensitiveContains("admin")
                }
                .forEach { style.removeLayer($0) }

            // Track country name layers so they can be shown only after a map tap.
            countryLabelLayerIDs = style.layers.compactMap { layer in
                guard layer.identifier.localizedCaseInsensitiveContains("country") else { return nil }
                guard layer is MLNSymbolStyleLayer else { return nil }
                return layer.identifier
            }
            setCountryLabels(visible: parent.selectedCoordinate != nil, on: mapView)

            // Guard against duplicate source/layer on style reload
            guard style.source(withIdentifier: srcID) == nil else { return }

            // Add countries GeoJSON as a source for our custom highlight
            guard let url = Bundle.main.url(forResource: "countries", withExtension: "geojson") else { return }
            let src = MLNShapeSource(identifier: srcID, url: url, options: nil)
            style.addSource(src)

            // Subtle gold fill (initially invisible — predicate=nil, opacity=0)
            let fill = MLNFillStyleLayer(identifier: fillID, source: src)
            fill.fillColor   = NSExpression(forConstantValue: UIColor(red: 0.84, green: 0.67, blue: 0.27, alpha: 1))
            fill.fillOpacity = NSExpression(forConstantValue: 0.0)
            style.addLayer(fill)

            // Pulsing gold border (initially invisible)
            let line = MLNLineStyleLayer(identifier: lineID, source: src)
            line.lineColor   = NSExpression(forConstantValue: UIColor(red: 0.84, green: 0.67, blue: 0.27, alpha: 1))
            line.lineWidth   = NSExpression(forConstantValue: 2.5)
            line.lineOpacity = NSExpression(forConstantValue: 0.0)
            style.addLayer(line)
        }

        // MARK: Highlight

        func updateHighlight(for coordinate: CLLocationCoordinate2D, on map: MLNMapView) {
            guard let style = map.style,
                  let code = countryIndex.countryCode(at: coordinate) else { return }

            // Match on whichever code property the GeoJSON feature uses
            let p1   = NSPredicate(format: "ISO_A3 == %@", code)
            let p2   = NSPredicate(format: "ADM0_A3 == %@", code)
            let pred = NSCompoundPredicate(orPredicateWithSubpredicates: [p1, p2])

            (style.layer(withIdentifier: fillID) as? MLNFillStyleLayer)?.predicate = pred
            (style.layer(withIdentifier: lineID) as? MLNLineStyleLayer)?.predicate = pred

            startPulsing()
        }

        func clearHighlight(on map: MLNMapView) {
            stopPulsing()
            guard let style = map.style else { return }
            if let fill = style.layer(withIdentifier: fillID) as? MLNFillStyleLayer {
                fill.fillOpacity = NSExpression(forConstantValue: 0.0)
                fill.predicate   = nil
            }
            if let line = style.layer(withIdentifier: lineID) as? MLNLineStyleLayer {
                line.lineOpacity = NSExpression(forConstantValue: 0.0)
                line.predicate   = nil
            }
        }

        func setCountryLabels(visible: Bool, on map: MLNMapView) {
            guard let style = map.style else { return }
            let opacity = visible ? 1.0 : 0.0
            for id in countryLabelLayerIDs {
                guard let labelLayer = style.layer(withIdentifier: id) as? MLNSymbolStyleLayer else { continue }
                labelLayer.textOpacity = NSExpression(forConstantValue: opacity)
            }
        }

        // MARK: Pulse animation

        private func startPulsing() {
            stopPulsing()
            pulsePhase = 0
            pulseTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 24.0, repeats: true) { [weak self] _ in
                guard let self, let map = self.mapView, let style = map.style else { return }
                self.pulsePhase += 0.12
                // Oscillate 0…1 with a sine wave
                let t = sin(self.pulsePhase) * 0.5 + 0.5
                (style.layer(withIdentifier: self.fillID) as? MLNFillStyleLayer)?
                    .fillOpacity = NSExpression(forConstantValue: 0.06 + 0.10 * t)
                (style.layer(withIdentifier: self.lineID) as? MLNLineStyleLayer)?
                    .lineOpacity = NSExpression(forConstantValue: 0.45 + 0.55 * t)
            }
        }

        func stopPulsing() {
            pulseTimer?.invalidate()
            pulseTimer = nil
        }

        deinit { stopPulsing() }
    }
}
