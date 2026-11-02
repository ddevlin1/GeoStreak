import SwiftUI

// MARK: - Campaign list

struct StoryModeView: View {
    @State private var campaigns: [StoryCampaign] = []
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.histBgDeep.ignoresSafeArea()
            Canvas { ctx, size in
                let c = GraphicsContext.Shading.color(Color.histGold.opacity(0.05))
                for i in 0...18 {
                    let x = CGFloat(i) / 18 * size.width
                    var p = Path(); p.move(to: .init(x: x, y: 0)); p.addLine(to: .init(x: x, y: size.height))
                    ctx.stroke(p, with: c, lineWidth: 0.5)
                }
                for j in 0...10 {
                    let y = CGFloat(j) / 10 * size.height
                    var p = Path(); p.move(to: .init(x: 0, y: y)); p.addLine(to: .init(x: size.width, y: y))
                    ctx.stroke(p, with: c, lineWidth: 0.5)
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        SmallCapsLabel("Historical campaigns")
                        Text("Story Mode")
                            .font(.system(size: 26, weight: .heavy))
                            .foregroundStyle(Color.histParchment)
                    }
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.histAged)
                            .frame(width: 30, height: 30)
                            .background(Color.histBgRaised, in: Circle())
                    }
                }
                .padding(.horizontal, 20).padding(.vertical, 16)
                GoldDivider()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
                        Text("Select a campaign to begin your journey")
                            .font(.subheadline)
                            .foregroundStyle(Color.histAged)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 4)

                        if campaigns.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "scroll.fill").font(.system(size: 44)).foregroundStyle(Color.histFaded)
                                Text("No campaigns available").font(.headline).foregroundStyle(Color.histFaded)
                            }
                            .frame(maxWidth: .infinity).padding(.vertical, 60)
                        } else {
                            ForEach(campaigns) { campaign in
                                NavigationLink(value: campaign) {
                                    StoryCampaignCardView(campaign: campaign)
                                }
                                .buttonStyle(.plain)
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20).padding(.vertical, 16).padding(.bottom, 24)
                }
            }
        }
        .onAppear { campaigns = StoryStore.load() }
        .navigationBarBackButtonHidden()
        .preferredColorScheme(.dark)
        .gameMusic()
    }
}

// MARK: - Campaign card

struct StoryCampaignCardView: View {
    let campaign: StoryCampaign

    var body: some View {
        HStack(spacing: 0) {
            // Coloured left stripe
            campaign.theme.accentColor
                .frame(width: 4)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            HStack(spacing: 12) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(campaign.theme.accentColor.opacity(0.14))
                        .frame(width: 44, height: 44)
                    Image(systemName: campaign.iconSymbol)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(campaign.theme.accentColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(campaign.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.histParchment)
                    Text(campaign.subtitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(campaign.theme.accentColor.opacity(0.85))
                    Text(campaign.description)
                        .font(.caption)
                        .foregroundStyle(Color.histAged)
                        .lineLimit(2)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.histFaded)
                    Text("\(campaign.totalChapters) ch · \(campaign.totalEvents) ev")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color.histFaded)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .leading)
        .background {
            if let imageName = campaign.backgroundImageName,
               let bgImage = UIImage(named: imageName) {
                Image(uiImage: bgImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(Color.black.opacity(0.50))
                    .clipped()
            } else {
                Color.histBgCard
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.histSeparator, lineWidth: 1))
    }
}

// MARK: - Campaign detail / chapter list

struct StorySelectionDetailView: View {
    let campaign: StoryCampaign
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            if let imageName = campaign.backgroundImageName,
               let bgImage = UIImage(named: imageName) {
                Image(uiImage: bgImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.40),
                        Color.black.opacity(0.68),
                        Color.histBgDeep.opacity(0.96)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            } else {
                // Deep gradient from campaign colour to near-black
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: campaign.theme.gradientColors[0], location: 0),
                        .init(color: campaign.theme.gradientColors[1], location: 0.45),
                        .init(color: Color.histBgDeep, location: 1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                // Nav bar
                HStack {
                    Button { dismiss() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.histParchment)
                    }
                    Spacer()
                    Image(systemName: campaign.iconSymbol)
                        .font(.headline).foregroundStyle(Color.histParchment.opacity(0.7))
                }
                .padding(.horizontal, 20).padding(.vertical, 14)

                // Campaign header
                VStack(alignment: .leading, spacing: 8) {
                    Text(campaign.subtitle.uppercased())
                        .font(.system(size: 9, weight: .semibold)).tracking(2)
                        .foregroundStyle(Color.histParchment.opacity(0.6))
                    Text(campaign.title)
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(Color.histParchment)
                    Text(campaign.description)
                        .font(.subheadline)
                        .foregroundStyle(Color.histParchment.opacity(0.8))
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20).padding(.bottom, 20)

                // Chapter list panel
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select chapter")
                        .font(.system(size: 10, weight: .semibold)).tracking(2)
                        .foregroundStyle(Color.histAged)
                        .padding(.horizontal, 20).padding(.top, 16)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(Array(campaign.chapters.enumerated()), id: \.element.id) { i, ch in
                                NavigationLink(value: ChapterDestination(campaign: campaign, chapterIndex: i)) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text("CHAPTER \(i + 1)")
                                                .font(.system(size: 9, weight: .semibold)).tracking(2)
                                                .foregroundStyle(Color.histAged)
                                            Text(ch.title)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundStyle(Color.histParchment)
                                        }
                                        Spacer()
                                        HStack(spacing: 4) {
                                            Image(systemName: "mappin.circle.fill")
                                                .font(.caption).foregroundStyle(campaign.theme.accentColor)
                                            Text("\(ch.events.count)")
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(Color.histAged)
                                        }
                                    }
                                    .padding(.horizontal, 16).padding(.vertical, 13)
                                    .background(Color.histBgCard)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.histSeparator, lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20).padding(.bottom, 28)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .background(
                    Color.histBgDeep
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .navigationBarBackButtonHidden()
    }
}

private extension StoryCampaign {
    var backgroundImageName: String? {
        switch id {
        case "ww1-campaign":
            return "WWIBG"
        case "ww2-campaign":
            return "WWIIBG"
        case "attila-campaign":
            return "AtillaBG"
        case "disney-location-journey":
            return "DisneyReefDeset"
        default:
            return nil
        }
    }
}

// MARK: - Game container (owns the StoryEngine)

struct StoryGameContainerView: View {
    let campaign: StoryCampaign
    let startChapterIndex: Int
    @StateObject private var engine: StoryEngine

    init(campaign: StoryCampaign, startChapterIndex: Int) {
        self.campaign = campaign
        self.startChapterIndex = startChapterIndex
        _engine = StateObject(wrappedValue: StoryEngine(campaign: campaign, startChapterIndex: startChapterIndex))
    }

    var body: some View {
        ZStack {
            switch engine.phase {
            case .chapterIntro:
                StoryChapterIntroView(engine: engine)
            case .campaignComplete:
                StoryCampaignCompleteView(engine: engine)
            default:
                StoryGameView(engine: engine)
            }
        }
        .navigationBarBackButtonHidden()
    }
}
