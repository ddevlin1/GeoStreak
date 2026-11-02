import Foundation
import CoreLocation
import SwiftUI

// MARK: - Campaign

struct StoryCampaign: Identifiable, Codable {
    let id: String
    let title: String
    let subtitle: String
    let description: String
    let theme: CampaignTheme
    let iconSymbol: String
    let chapters: [StoryChapter]

    var totalEvents: Int { chapters.flatMap(\.events).count }
    var totalChapters: Int { chapters.count }
}

// MARK: - Chapter

struct StoryChapter: Identifiable, Codable {
    let id: String
    let title: String
    let intro: String
    let events: [StoryEvent]
}

// MARK: - Event

struct StoryEvent: Identifiable, Codable {
    let id: String
    let title: String
    let year: String
    let narrative: String
    let revealText: String
    let city: String
    let country: String
    let countryCode: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Theme

enum CampaignTheme: String, Codable, CaseIterable {
    case crimson, amber, emerald, sapphire, violet
}

extension CampaignTheme {
    /// Full-screen gradient (chapter intro, campaign complete).
    /// All dark enough that white / histParchment text is ≥ 4.5 : 1.
    var gradientColors: [Color] {
        switch self {
        case .crimson:  return [Color(red: 0.55, green: 0.10, blue: 0.09), Color(red: 0.28, green: 0.04, blue: 0.04)]
        case .amber:    return [Color(red: 0.60, green: 0.32, blue: 0.06), Color(red: 0.32, green: 0.16, blue: 0.03)]
        case .emerald:  return [Color(red: 0.10, green: 0.36, blue: 0.20), Color(red: 0.05, green: 0.20, blue: 0.11)]
        case .sapphire: return [Color(red: 0.10, green: 0.22, blue: 0.52), Color(red: 0.05, green: 0.11, blue: 0.30)]
        case .violet:   return [Color(red: 0.30, green: 0.09, blue: 0.50), Color(red: 0.16, green: 0.04, blue: 0.28)]
        }
    }

    /// Vivid accent for icons, left-border stripes, and decorative labels.
    /// Use on dark leather backgrounds; not for body text.
    var accentColor: Color {
        switch self {
        case .crimson:  return Color(red: 0.88, green: 0.30, blue: 0.26)
        case .amber:    return Color(red: 0.92, green: 0.62, blue: 0.18)
        case .emerald:  return Color(red: 0.24, green: 0.76, blue: 0.44)
        case .sapphire: return Color(red: 0.30, green: 0.58, blue: 0.95)
        case .violet:   return Color(red: 0.64, green: 0.28, blue: 0.94)
        }
    }
}

// MARK: - Navigation helpers

extension StoryCampaign: Hashable {
    static func == (lhs: StoryCampaign, rhs: StoryCampaign) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct ChapterDestination: Hashable {
    let campaign: StoryCampaign
    let chapterIndex: Int
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.campaign.id == rhs.campaign.id && lhs.chapterIndex == rhs.chapterIndex
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(campaign.id)
        hasher.combine(chapterIndex)
    }
}

// MARK: - Safe subscript

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
