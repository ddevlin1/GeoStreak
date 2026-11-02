import SwiftUI

struct StoryCampaignCompleteView: View {
    @ObservedObject var engine: StoryEngine
    @Environment(\.dismiss) var dismiss

    private var accuracy: Double {
        engine.totalGuessed > 0 ? Double(engine.correctCount) / Double(engine.totalGuessed) * 100 : 0
    }

    var body: some View {
        ZStack {
            Color.histBgDeep.ignoresSafeArea()

            // Subtle vignette from campaign colour
            RadialGradient(
                gradient: Gradient(colors: [
                    engine.campaign.theme.gradientColors[0].opacity(0.35),
                    Color.clear
                ]),
                center: .top,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // ── Trophy ────────────────────────────────────────────────
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.histGold.opacity(0.12))
                            .frame(width: 96, height: 96)
                        Circle()
                            .strokeBorder(Color.histGold.opacity(0.4), lineWidth: 1.5)
                            .frame(width: 96, height: 96)
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.histGold)
                    }

                    VStack(spacing: 4) {
                        Text("Campaign Complete")
                            .font(.system(size: 26, weight: .heavy))
                            .foregroundStyle(Color.histParchment)
                        Text(engine.campaign.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.histAged)
                    }
                }

                // ── Score ─────────────────────────────────────────────────
                VStack(spacing: 6) {
                    Text("FINAL SCORE")
                        .font(.system(size: 9, weight: .semibold)).tracking(2.5)
                        .foregroundStyle(Color.histFaded)
                    Text("\(engine.score)")
                        .font(.system(size: 52, weight: .heavy))
                        .foregroundStyle(Color.histGold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.histBgCard)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.histSeparator, lineWidth: 1))
                .padding(.top, 28)

                // ── Stats row ─────────────────────────────────────────────
                HStack(spacing: 12) {
                    StatCell(
                        value: "\(accuracy.formatted(.number.precision(.fractionLength(0))))%",
                        label: "Accuracy"
                    )
                    StatCell(
                        value: "\(engine.correctCount) / \(engine.totalGuessed)",
                        label: "Located"
                    )
                }
                .padding(.top, 12)

                Spacer()

                // ── Done ──────────────────────────────────────────────────
                Button { dismiss() } label: {
                    Text("Return to Campaigns")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color.histBgDeep)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.histGold, in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
        }
        .gameMusic()
    }
}

private struct StatCell: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.histParchment)
            Text(label.uppercased())
                .font(.system(size: 9, weight: .semibold)).tracking(1.5)
                .foregroundStyle(Color.histFaded)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.histBgCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.histSeparator, lineWidth: 1))
    }
}
