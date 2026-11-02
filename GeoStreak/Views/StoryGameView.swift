import SwiftUI
import CoreLocation

struct StoryGameView: View {
    @ObservedObject var engine: StoryEngine
    @Environment(\.dismiss) private var dismiss
    @State private var guess: CLLocationCoordinate2D?

    private var answerCoordinate: CLLocationCoordinate2D? {
        if case .eventReveal = engine.phase { return engine.currentEvent?.coordinate }
        return nil
    }

    var body: some View {
        ZStack(alignment: .top) {
            MapView(selectedCoordinate: $guess, answerCoordinate: answerCoordinate)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Campaign / progress bar ───────────────────────────────
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.histParchment)
                            .frame(width: 32, height: 32)
                            .background(Color.histBgRaised, in: Circle())
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text(engine.campaign.title.uppercased())
                            .font(.system(size: 9, weight: .semibold))
                            .tracking(2)
                            .foregroundStyle(Color.histGold)
                        Text(engine.currentChapter?.title ?? "")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.histParchment)
                            .lineLimit(1)
                    }
                    Spacer()
                    Text(engine.chapterProgress)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.histAged)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color.histBgRaised, in: Capsule())
                }
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background {
                    Color.histBgCard.opacity(0.82)
                        .ignoresSafeArea(edges: .top)
                }
                .overlay(alignment: .bottom) { Color.histSeparator.frame(height: 1) }

                Spacer()

                // ── Event card ────────────────────────────────────────────
                VStack(spacing: 10) {
                    if let event = engine.currentEvent {
                        // Narrative card
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                // Year badge
                                Text(event.year)
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(0.5)
                                    .foregroundStyle(Color.histGold)
                                    .padding(.horizontal, 8).padding(.vertical, 3)
                                    .background(Color.histGold.opacity(0.12), in: Capsule())
                                    .overlay(Capsule().strokeBorder(Color.histGold.opacity(0.3), lineWidth: 0.5))
                                Spacer()
                                Image(systemName: engine.campaign.iconSymbol)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(engine.campaign.theme.accentColor)
                            }
                            Text(event.title)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(Color.histParchment)
                                .lineLimit(2)
                            Text(event.narrative)
                                .font(.subheadline)
                                .foregroundStyle(Color.histAged)
                                .lineLimit(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(14)
                        .background(Color.histBgCard)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.histSeparator, lineWidth: 1))

                        // Action
                        if case .guessing = engine.phase {
                            Button {
                                guard let guess else { return }
                                engine.submit(guess: guess)
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: guess == nil ? "mappin" : "mappin.and.ellipse")
                                    Text(guess == nil ? "Tap the map to place your pin" : "Confirm Location")
                                }
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(guess == nil ? Color.histAged : Color.histBgDeep)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(guess == nil ? Color.histBgRaised : Color.histGold,
                                            in: RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(guess == nil)

                        } else if case .eventReveal(let isCorrect, let distance) = engine.phase {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 8) {
                                    Image(systemName: isCorrect ? "checkmark.seal.fill" : "xmark.seal.fill")
                                    Text(isCorrect ? "Located" : "Off the mark")
                                        .font(.headline.weight(.semibold))
                                    Spacer()
                                    Text("\(Int(distance)) km")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Color.histAged)
                                }
                                .foregroundStyle(isCorrect ? Color.histGreen : Color(red: 0.90, green: 0.52, blue: 0.18))

                                Text(event.revealText)
                                    .font(.caption)
                                    .foregroundStyle(Color.histAged)
                                    .lineLimit(5)
                                    .fixedSize(horizontal: false, vertical: true)

                                Button {
                                    guess = nil
                                    engine.advance()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.right")
                                        Text("Continue")
                                    }
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Color.histBgDeep)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                                    .background(Color.histGold, in: RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding(14)
                            .background(Color.histBgCard)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.histSeparator, lineWidth: 1))
                        }
                    }
                }
                .padding(12)
                .background {
                    Color.histBgDeep.opacity(0.82)
                        .ignoresSafeArea(edges: .bottom)
                }
                .overlay(alignment: .top) { Color.histSeparator.frame(height: 1) }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .gameMusic()
        .onChange(of: engine.eventIndex)   { _, _ in guess = nil }
        .onChange(of: engine.chapterIndex) { _, _ in guess = nil }
    }
}
