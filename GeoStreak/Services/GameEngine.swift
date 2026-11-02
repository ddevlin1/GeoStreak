import Foundation
import CoreLocation

@MainActor
final class GameEngine: ObservableObject {
    @Published private(set) var current: Challenge?
    @Published private(set) var streak = 0
    @Published private(set) var bestStreak = UserDefaults.standard.integer(forKey: "bestStreak")
    @Published private(set) var livesRemaining = 1
    @Published private(set) var lastResult: GuessResult?
    @Published private(set) var isFinished = false

    let settings: GameSettings
    private let allChallenges: [Challenge]
    private let countryIndex = CountryIndex()
    private var usedIDs = Set<UUID>()

    init(settings: GameSettings) {
        self.settings = settings
        self.allChallenges = ChallengeStore.load().filter { challenge in
            switch settings.clueType {
            case .city: return !challenge.city.isEmpty
            case .landmark: return !challenge.landmark.isEmpty
            case .history: return !challenge.historyClue.isEmpty
            }
        }
        self.livesRemaining = settings.lives
        nextChallenge()
    }

    func submit(guess: CLLocationCoordinate2D) {
        guard let current, !isFinished else { return }
        let answer = CLLocation(latitude: current.latitude, longitude: current.longitude)
        let guessed = CLLocation(latitude: guess.latitude, longitude: guess.longitude)
        let distance = guessed.distance(from: answer) / 1000
        let guessedCountry = countryIndex.countryCode(at: guess)

        let correct: Bool
        switch settings.accuracyRule {
        case .country:
            correct = guessedCountry == current.countryCode
        case .kilometers(let radius):
            correct = distance <= Double(radius)
        }

        lastResult = GuessResult(isCorrect: correct, distanceKilometers: distance, guessedCountryCode: guessedCountry)
        if correct {
            streak += 1
            if streak > bestStreak {
                bestStreak = streak
                UserDefaults.standard.set(bestStreak, forKey: "bestStreak")
            }
        } else {
            livesRemaining -= 1
            if livesRemaining <= 0 { isFinished = true }
        }
    }

    func continueAfterResult() {
        lastResult = nil
        if !isFinished { nextChallenge() }
    }

    func restart() {
        streak = 0
        livesRemaining = settings.lives
        isFinished = false
        lastResult = nil
        usedIDs.removeAll()
        nextChallenge()
    }

    private func nextChallenge() {
        if usedIDs.count >= allChallenges.count { usedIDs.removeAll() }
        let candidates = allChallenges.filter { !usedIDs.contains($0.id) }
        current = candidates.randomElement()
        if let current { usedIDs.insert(current.id) }
    }
}
