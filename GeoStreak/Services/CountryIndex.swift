import Foundation
import CoreLocation

final class CountryIndex {
    private struct FeatureCollection: Decodable { let features: [Feature] }
    private struct Feature: Decodable {
        let properties: Properties
        let geometry: Geometry
    }
    private struct Properties: Decodable {
        let ADM0_A3: String?
        let ISO_A3: String?
    }
    private struct Geometry: Decodable {
        let type: String
        let coordinates: JSONValue
    }
    private enum JSONValue: Decodable {
        case number(Double), array([JSONValue]), object([String: JSONValue]), string(String), bool(Bool), null
        init(from decoder: Decoder) throws {
            let c = try decoder.singleValueContainer()
            if c.decodeNil() { self = .null }
            else if let v = try? c.decode(Double.self) { self = .number(v) }
            else if let v = try? c.decode(String.self) { self = .string(v) }
            else if let v = try? c.decode(Bool.self) { self = .bool(v) }
            else if let v = try? c.decode([JSONValue].self) { self = .array(v) }
            else { self = .object(try c.decode([String: JSONValue].self)) }
        }
    }

    private struct CountryPolygon {
        let code: String
        let polygons: [[CLLocationCoordinate2D]]
    }

    private var countries: [CountryPolygon] = []

    init() {
        guard let url = Bundle.main.url(forResource: "countries", withExtension: "geojson"),
              let data = try? Data(contentsOf: url),
              let collection = try? JSONDecoder().decode(FeatureCollection.self, from: data) else { return }

        countries = collection.features.compactMap { feature in
            let code = feature.properties.ISO_A3 ?? feature.properties.ADM0_A3
            guard let code, code != "-99" else { return nil }
            return CountryPolygon(code: code, polygons: Self.extractPolygons(feature.geometry))
        }
    }

    func countryCode(at coordinate: CLLocationCoordinate2D) -> String? {
        countries.first { country in
            country.polygons.contains { Self.point(coordinate, isInside: $0) }
        }?.code
    }

    private static func extractPolygons(_ geometry: Geometry) -> [[CLLocationCoordinate2D]] {
        guard case .array(let root) = geometry.coordinates else { return [] }
        let polygonArrays: [JSONValue]
        if geometry.type == "Polygon" { polygonArrays = [JSONValue.array(root)] }
        else if geometry.type == "MultiPolygon" { polygonArrays = root }
        else { return [] }

        return polygonArrays.compactMap { polygonValue in
            guard case .array(let rings) = polygonValue,
                  let firstRing = rings.first,
                  case .array(let points) = firstRing else { return nil }
            return points.compactMap { point in
                guard case .array(let pair) = point,
                      pair.count >= 2,
                      case .number(let lon) = pair[0],
                      case .number(let lat) = pair[1] else { return nil }
                return CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
        }
    }

    private static func point(_ p: CLLocationCoordinate2D, isInside polygon: [CLLocationCoordinate2D]) -> Bool {
        guard polygon.count > 2 else { return false }
        var inside = false
        var j = polygon.count - 1
        for i in polygon.indices {
            let a = polygon[i], b = polygon[j]
            let intersects = ((a.latitude > p.latitude) != (b.latitude > p.latitude)) &&
                (p.longitude < (b.longitude - a.longitude) * (p.latitude - a.latitude) /
                 ((b.latitude - a.latitude) == 0 ? 0.0000001 : (b.latitude - a.latitude)) + a.longitude)
            if intersects { inside.toggle() }
            j = i
        }
        return inside
    }
}
