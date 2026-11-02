import Foundation
import CoreLocation

enum ClueType: String, CaseIterable, Identifiable, Codable {
    case city = "City"
    case landmark = "Landmark"
    case history = "Historical clue"
    var id: String { rawValue }
}

enum AccuracyRule: Hashable, Codable, Identifiable {
    case country
    case kilometers(Int)

    var id: String { label }
    var label: String {
        switch self {
        case .country: return "Correct country"
        case .kilometers(let km): return "Within \(km) km"
        }
    }

    static let presets: [AccuracyRule] = [.country, .kilometers(5), .kilometers(50), .kilometers(250)]
}

struct GameSettings: Hashable {
    var clueType: ClueType = .city
    var accuracyRule: AccuracyRule = .country
    var lives: Int = 1
    var revealDistanceAfterGuess = true
}

struct Challenge: Identifiable, Codable, Equatable {
    let id: UUID
    let city: String
    let country: String
    let countryCode: String
    let latitude: Double
    let longitude: Double
    let landmark: String
    let historyClue: String
    let difficulty: Int

    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }

    func clue(for type: ClueType) -> String {
        switch type {
        case .city: return city
        case .landmark: return landmark
        case .history: return historyClue
        }
    }
}

struct GuessResult {
    let isCorrect: Bool
    let distanceKilometers: Double
    let guessedCountryCode: String?
}
