import SwiftUI

struct StoryChapterIntroView: View {
    @ObservedObject var engine: StoryEngine
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Rich gradient – campaign colour fading to deep leather
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: engine.campaign.theme.gradientColors[0], location: 0),
                    .init(color: engine.campaign.theme.gradientColors[1], location: 0.5),
                    .init(color: Color.histBgDeep, location: 1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Back button row ──────────────────────────────────
                HStack {
                    Button { dismiss() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Campaigns")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.histParchment.opacity(0.85))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20).padding(.top, 14).padding(.bottom, 8)

                Spacer()

                // ── Chapter badge ─────────────────────────────────────────
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.histBgDeep.opacity(0.45))
                            .frame(width: 72, height: 72)
                        Circle()
                            .strokeBorder(Color.histGold.opacity(0.5), lineWidth: 1.5)
                            .frame(width: 72, height: 72)
                        Image(systemName: engine.campaign.iconSymbol)
                            .font(.system(size: 28))
                            .foregroundStyle(Color.histGold)
                    }

                    // Chapter label
                    VStack(spacing: 6) {
                        Text("\(engine.campaign.title.uppercased())  ·  CHAPTER \(engine.chapterIndex + 1) OF \(engine.campaign.chapters.count)")
                            .font(.system(size: 10, weight: .semibold))
                            .tracking(1.5)
                            .foregroundStyle(Color.histParchment.opacity(0.55))

                        Text(engine.currentChapter?.title ?? "")
                            .font(.system(size: 28, weight: .heavy))
                            .foregroundStyle(Color.histParchment)
                            .multilineTextAlignment(.center)
                    }

                    // Intro text on a dark card
                    Text(engine.currentChapter?.intro ?? "")
                        .font(.body)
                        .foregroundStyle(Color.histParchment.opacity(0.82))
                        .multilineTextAlignment(.center)
                        .lineLimit(6)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(16)
                        .background(Color.histBgDeep.opacity(0.5), in: RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.histSeparator, lineWidth: 1))

                    // Event count chip
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(Color.histGold)
                        Text("\(engine.currentChapter?.events.count ?? 0) events to locate")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.histParchment)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Color.histBgDeep.opacity(0.5), in: Capsule())
                    .overlay(Capsule().strokeBorder(Color.histGold.opacity(0.4), lineWidth: 1))
                }
                .padding(.horizontal, 28)

                Spacer()

                // ── CTA ───────────────────────────────────────────────────
                Button { engine.beginChapter() } label: {
                    HStack(spacing: 8) {
                        Text("Begin Chapter")
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.histBgDeep)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color.histGold, in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 28).padding(.bottom, 40)
            }
        }
        .gameMusic()
    }
}
