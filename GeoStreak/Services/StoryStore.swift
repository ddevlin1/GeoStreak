import Foundation

enum StoryStore {
    static func load() -> [StoryCampaign] {
        guard let url = Bundle.main.url(forResource: "stories", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let campaigns = try? JSONDecoder().decode([StoryCampaign].self, from: data) else {
            return []
        }
        return campaigns
    }
}
