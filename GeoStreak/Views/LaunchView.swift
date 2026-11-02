import SwiftUI

struct LaunchView: View {
    @State private var isFinished = false
    @State private var buttonOpacity: Double = 0

    private func goToMenu() {
        withAnimation(.easeInOut(duration: 0.5)) { isFinished = true }
    }

    var body: some View {
        if isFinished {
            HomeView()
                .transition(.opacity)
        } else {
            ZStack {
                // ── Full-screen hero image ────────────────────────────
                if let uiImage = UIImage(named: "HistoryUnmappedImage") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                } else {
                    Color.histBgDeep.ignoresSafeArea()
                }

                // ── Bottom gradient scrim ─────────────────────────────
                VStack {
                    Spacer()
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.82)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 260)
                }
                .ignoresSafeArea(edges: .bottom)

                // ── "Tap to Play" button ──────────────────────────────
                VStack {
                    Spacer()
                    Button(action: goToMenu) {
                        Text("Tap to Play")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.histBgDeep)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.histGold, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 52)
                }
                .opacity(buttonOpacity)
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeIn(duration: 0.9).delay(0.5)) {
                    buttonOpacity = 1
                }
            }
        }
    }
}
