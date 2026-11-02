import SwiftUI
import CoreLocation

struct GameView: View {
    @StateObject var engine: GameEngine
    @State private var guess: CLLocationCoordinate2D?

    var body: some View {
        ZStack(alignment: .top) {
            MapView(selectedCoordinate: $guess,
                    answerCoordinate: engine.lastResult == nil ? nil : engine.current?.coordinate)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Stats bar ────────────────────────────────────────────
                HStack {
                    // Streak
                    HStack(spacing: 5) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(Color.histGold)
                        Text("\(engine.streak)")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color.histParchment)
                    }

                    Spacer()

                    // Best
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.caption)
                            .foregroundStyle(Color.histGold.opacity(0.7))
                        Text("Best \(engine.bestStreak)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.histAged)
                    }

                    Spacer()

                    // Lives
                    HStack(spacing: 5) {
                        Text("\(engine.livesRemaining)")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color.histRed)
                        Image(systemName: "heart.fill")
                            .foregroundStyle(Color.histRed)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background {
                    Color.histBgCard.opacity(0.82)
                        .ignoresSafeArea(edges: .top)
                }
                .overlay(alignment: .bottom) {
                    Color.histSeparator.frame(height: 1)
                }

                Spacer()

                // ── Clue / result card ────────────────────────────────────
                VStack(spacing: 12) {
                    if let challenge = engine.current {
                        VStack(spacing: 6) {
                            Text(engine.settings.clueType.rawValue.uppercased())
                                .font(.system(size: 9, weight: .semibold))
                                .tracking(2)
                                .foregroundStyle(Color.histFaded)

                            Text(challenge.clue(for: engine.settings.clueType))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color.histParchment)
                                .multilineTextAlignment(.center)

                            Text(engine.settings.accuracyRule.label)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.histGold)
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(Color.histGold.opacity(0.12), in: Capsule())
                        }
                    }

                    if let result = engine.lastResult {
                        // Result state
                        VStack(spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: result.isCorrect ? "checkmark.seal.fill" : "xmark.seal.fill")
                                Text(result.isCorrect ? "Correct!" : "Missed it")
                                    .font(.headline.weight(.semibold))
                            }
                            .foregroundStyle(result.isCorrect ? Color.histGreen : Color.histRed)

                            Text("\(result.distanceKilometers.formatted(.number.precision(.fractionLength(0)))) km from target")
                                .font(.subheadline)
                                .foregroundStyle(Color.histAged)

                            if let current = engine.current {
                                Text("\(current.city), \(current.country)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.histParchment)
                            }

                            Button(engine.isFinished ? "Play Again" : "Next Clue") {
                                guess = nil
                                engine.isFinished ? engine.restart() : engine.continueAfterResult()
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.histBgDeep)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.histGold, in: RoundedRectangle(cornerRadius: 11))
                        }
                    } else {
                        // Guess state
                        Button {
                            guard let guess else { return }
                            engine.submit(guess: guess)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: guess == nil ? "mappin" : "mappin.and.ellipse")
                                Text(guess == nil ? "Tap the map to place your pin" : "Lock In Location")
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(guess == nil ? Color.histAged : Color.histBgDeep)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(
                                guess == nil ? Color.histBgRaised : Color.histGold,
                                in: RoundedRectangle(cornerRadius: 11)
                            )
                        }
                        .disabled(guess == nil)
                    }
                }
                .padding(16)
                .background {
                    Color.histBgCard.opacity(0.82)
                        .ignoresSafeArea(edges: .bottom)
                }
                .overlay(alignment: .top) {
                    Color.histSeparator.frame(height: 1)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .gameMusic()
    }
}
