import Foundation

enum ChallengeStore {
    static func load() -> [Challenge] {
        guard let url = Bundle.main.url(forResource: "challenges", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let values = try? JSONDecoder().decode([Challenge].self, from: data) else {
            return []
        }
        return values
    }
}
