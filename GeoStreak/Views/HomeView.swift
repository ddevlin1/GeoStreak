import SwiftUI

struct HomeView: View {
    @State private var settings = GameSettings()
    @State private var startGame = false
    @State private var showStoryMode = false

    private var bestStreak: Int { UserDefaults.standard.integer(forKey: "bestStreak") }

    private var menuBackground: Image? {
        if let uiImage = UIImage(named: "Menubackground")
            ?? UIImage(named: "Menubackground.png")
            ?? UIImage(named: "MenuBackground")
            ?? UIImage(named: "MenuBackground.png") {
            return Image(uiImage: uiImage)
        }
        return nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // ── Anchor: forces ZStack to fill the screen, not grow with scroll content
                Color.clear.ignoresSafeArea()

                // ── Background image + scrim ──────────────────────────
                if let menuBackground {
                    menuBackground
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                }

                LinearGradient(
                    stops: [
                        .init(color: Color.black.opacity(0.68), location: 0),
                        .init(color: Color.black.opacity(0.42), location: 0.38),
                        .init(color: Color.black.opacity(0.62), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // ── Scrollable content ────────────────────────────────
                GeometryReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {

                        // ── Masthead ──────────────────────────────────────
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 14) {
                                Image(systemName: "globe.europe.africa.fill")
                                    .font(.system(size: 42))
                                    .foregroundStyle(Color.histGold)
                                    .shadow(color: Color.histGold.opacity(0.4), radius: 12)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("History Unmapped")
                                        .font(.system(size: 28, weight: .heavy))
                                        .foregroundStyle(Color.histParchment)
                                    Text("HISTORY  ·  GEOGRAPHY  ·  STRATEGY")
                                        .font(.system(size: 9, weight: .semibold))
                                        .tracking(1.5)
                                        .foregroundStyle(Color.histAged)
                                }
                            }
                            if bestStreak > 0 {
                                HStack(spacing: 5) {
                                    Image(systemName: "flame.fill")
                                    Text("Personal best: \(bestStreak)")
                                }
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.histGold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.histGold.opacity(0.12), in: Capsule())
                                .overlay(Capsule().strokeBorder(Color.histGold.opacity(0.3), lineWidth: 1))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .background(Color.black.opacity(0.45))

                        GoldDivider()

                        // ── Mode selection ────────────────────────────────
                        VStack(alignment: .leading, spacing: 12) {
                            SmallCapsLabel("Choose your mode")
                            Button { showStoryMode = true } label: {
                                HomeModeCard(
                                    icon: "scroll.fill",
                                    title: "Story Mode",
                                    subtitle: "Journey through WWI, the Roman Empire, Attila & more",
                                    accentColor: Color.histGold
                                )
                            }
                            .buttonStyle(.plain)
                            Button { startGame = true } label: {
                                HomeModeCard(
                                    icon: "flame.fill",
                                    title: "Quick Play",
                                    subtitle: "Race through clues and build the longest streak you can",
                                    accentColor: Color(red: 0.88, green: 0.34, blue: 0.22)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)

                        GoldDivider()

                        // ── Quick Play settings ───────────────────────────
                        VStack(alignment: .leading, spacing: 12) {
                            SmallCapsLabel("Quick Play settings")
                            VStack(spacing: 0) {
                                SettingRowView(label: "Clue type", icon: "text.magnifyingglass") {
                                    Menu {
                                        ForEach(ClueType.allCases) { t in Button(t.rawValue) { settings.clueType = t } }
                                    } label: { ChevronMenuLabel(settings.clueType.rawValue) }
                                }
                                Color.histSeparator.frame(height: 1).padding(.horizontal, 16)
                                SettingRowView(label: "Accuracy", icon: "scope") {
                                    Menu {
                                        ForEach(AccuracyRule.presets) { r in Button(r.label) { settings.accuracyRule = r } }
                                    } label: { ChevronMenuLabel(settings.accuracyRule.label) }
                                }
                                Color.histSeparator.frame(height: 1).padding(.horizontal, 16)
                                SettingRowView(label: "Lives", icon: "heart.fill") {
                                    HStack(spacing: 14) {
                                        Button { if settings.lives > 1 { settings.lives -= 1 } } label: {
                                            Image(systemName: "minus").font(.caption.weight(.bold))
                                                .frame(width: 26, height: 26)
                                                .background(Color.histBgRaised, in: Circle())
                                                .foregroundStyle(Color.histParchment)
                                        }
                                        Text("\(settings.lives)").font(.subheadline.weight(.bold)).foregroundStyle(Color.histGold).frame(minWidth: 18)
                                        Button { if settings.lives < 3 { settings.lives += 1 } } label: {
                                            Image(systemName: "plus").font(.caption.weight(.bold))
                                                .frame(width: 26, height: 26)
                                                .background(Color.histBgRaised, in: Circle())
                                                .foregroundStyle(Color.histParchment)
                                        }
                                    }
                                }
                            }
                            .background(Color.histBgCard.opacity(0.92))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.histGold.opacity(0.38), lineWidth: 1))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)

                        // ── CTA ──────────────────────────────────────────
                        Button { startGame = true } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                Text("Begin Quick Play")
                            }
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Color.histBgDeep)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.histGold, in: RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal, 20)

                        GoldDivider().padding(.top, 24)

                        // ── Roadmap chips ────────────────────────────────
                        HStack(spacing: 12) {
                            RoadmapChip(icon: "calendar",           text: "Daily seeds")
                            RoadmapChip(icon: "bolt.fill",           text: "Risk rounds")
                            RoadmapChip(icon: "square.stack.3d.up", text: "Themed packs")
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .padding(.bottom, 24)
                        }
                        .padding(.top, proxy.safeAreaInsets.top + 8)
                        .frame(width: proxy.size.width, alignment: .top)
                    }
                }
                .navigationDestination(isPresented: $startGame) {
                    GameView(engine: GameEngine(settings: settings))
                }
                .navigationDestination(isPresented: $showStoryMode) {
                    StoryModeView()
                }
                .navigationDestination(for: StoryCampaign.self) { campaign in
                    StorySelectionDetailView(campaign: campaign)
                }
                .navigationDestination(for: ChapterDestination.self) { dest in
                    StoryGameContainerView(campaign: dest.campaign, startChapterIndex: dest.chapterIndex)
                }
            }
            .preferredColorScheme(.dark)
            .menuMusic()
        }
    }
}

// MARK: - Home sub-components

private struct HomeModeCard: View {
    let icon: String; let title: String; let subtitle: String; let accentColor: Color
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 11).fill(accentColor.opacity(0.15)).frame(width: 46, height: 46)
                Image(systemName: icon).font(.system(size: 20, weight: .semibold)).foregroundStyle(accentColor)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 16, weight: .semibold)).foregroundStyle(Color.histParchment)
                Text(subtitle).font(.caption).foregroundStyle(Color.histAged).lineLimit(2)
            }
            Spacer(minLength: 4)
            Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(Color.histFaded)
        }
        .padding(14)
        .background(Color.histBgCard.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.histGold.opacity(0.38), lineWidth: 1))
    }
}

struct SettingRowView<C: View>: View {
    let label: String; let icon: String; @ViewBuilder let control: () -> C
    var body: some View {
        HStack {
            Label(label, systemImage: icon).font(.subheadline.weight(.medium)).foregroundStyle(Color.histParchment)
            Spacer()
            control()
        }
        .padding(.horizontal, 16).padding(.vertical, 13)
    }
}

struct ChevronMenuLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
            Image(systemName: "chevron.up.chevron.down").font(.system(size: 9, weight: .bold))
        }
        .font(.subheadline.weight(.semibold)).foregroundStyle(Color.histGold)
    }
}

private struct RoadmapChip: View {
    let icon: String; let text: String
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 14)).foregroundStyle(Color.histAged)
            Text(text).font(.system(size: 9, weight: .semibold)).tracking(0.5).foregroundStyle(Color.histAged).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 10)
        .background(Color.histBgCard.opacity(0.88)).clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.histGold.opacity(0.32), lineWidth: 1))
    }
}

// MARK: - Shared layout atoms (used by story views too)

struct GoldDivider: View {
    var body: some View { Color.histGold.opacity(0.40).frame(height: 1) }
}

struct SmallCapsLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .semibold)).tracking(2).foregroundStyle(Color.histAged)
    }
}
