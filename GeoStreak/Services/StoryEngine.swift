import Foundation
import CoreLocation

@MainActor
final class StoryEngine: ObservableObject {

    // MARK: - Phase

    enum Phase {
        case chapterIntro
        case guessing
        case eventReveal(isCorrect: Bool, distance: Double)
        case campaignComplete
    }

    // MARK: - Published state

    let campaign: StoryCampaign

    @Published private(set) var chapterIndex = 0
    @Published private(set) var eventIndex = 0
    @Published private(set) var phase: Phase = .chapterIntro
    @Published private(set) var completedCoordinates: [CLLocationCoordinate2D] = []
    @Published private(set) var score = 0
    @Published private(set) var correctCount = 0
    @Published private(set) var totalGuessed = 0

    // MARK: - Derived

    var currentChapter: StoryChapter? { campaign.chapters[safe: chapterIndex] }
    var currentEvent: StoryEvent? { currentChapter?.events[safe: eventIndex] }

    var chapterProgress: String {
        guard let chapter = currentChapter else { return "" }
        return "Event \(eventIndex + 1) of \(chapter.events.count)"
    }

    // MARK: - Init

    init(campaign: StoryCampaign, startChapterIndex: Int = 0) {
        self.campaign = campaign
        self.chapterIndex = startChapterIndex
    }

    // MARK: - Actions

    func beginChapter() {
        phase = .guessing
    }

    func submit(guess: CLLocationCoordinate2D) {
        guard let event = currentEvent else { return }
        guard case .guessing = phase else { return }

        let answer = CLLocation(latitude: event.latitude, longitude: event.longitude)
        let guessed = CLLocation(latitude: guess.latitude, longitude: guess.longitude)
        let distanceKm = guessed.distance(from: answer) / 1_000

        totalGuessed += 1
        completedCoordinates.append(event.coordinate)

        // Within 500 km scores; tighter = more points (max 500, min 10)
        let isCorrect = distanceKm < 500
        if isCorrect {
            score += max(500 - Int(distanceKm), 10)
            correctCount += 1
        }

        phase = .eventReveal(isCorrect: isCorrect, distance: distanceKm)
    }

    func advance() {
        guard let chapter = currentChapter else { return }

        let nextEvent = eventIndex + 1
        if nextEvent < chapter.events.count {
            eventIndex = nextEvent
            phase = .guessing
        } else {
            let nextChapter = chapterIndex + 1
            if nextChapter < campaign.chapters.count {
                chapterIndex = nextChapter
                eventIndex = 0
                phase = .chapterIntro
            } else {
                phase = .campaignComplete
            }
        }
    }
}
