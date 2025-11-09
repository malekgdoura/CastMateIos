import SwiftUI

struct SplashWelcomeView: View {
    let token: String
    let user: UserInfo?
    @Environment(\.dismiss) private var dismiss
    @AppStorage("authToken") private var authToken: String?
    @State private var isActive = true

    @State private var showSpotlight = false
    @State private var showHome = false
    @State private var glowPulse = false

    var body: some View {
        ZStack {
            // BACKGROUND: white
            Color.white.ignoresSafeArea()

            // SPOTLIGHT + CIRCLE (only visible before showing home)
            if !showHome {
                ZStack {
                    // LEFT spotlight beam
                    // Left beam
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.07),
                            Color(red: 0.039, green: 0.000, blue: 0.329) // #0A0054
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: 160, height: 500)
                    .rotationEffect(.degrees(-28))
                    .offset(x: -80, y: -100)
                    .blur(radius: 4)

                    // Right beam
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.07),
                            Color(red: 0.039, green: 0.000, blue: 0.329) // #0A0054
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: 160, height: 500)
                    .rotationEffect(.degrees(28))
                    .offset(x: 80, y: -100)
                    .blur(radius: 4)

                    // CENTER glowing circle
                    // Center glowing circle (stage focus)
                    // Center glowing circle with logo
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.271, green: 0.275, blue: 0.565), // #454690
                                        Color(red: 0.039, green: 0.000, blue: 0.329)  // #0A0054
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 180, height: 180)
                            .shadow(color: Color(hex: "0A0054").opacity(0.35), radius: 24, y: 10)
                            .scaleEffect(glowPulse ? 1.08 : 0.96)
                            .opacity(showSpotlight ? 1 : 0.95)
                            .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: glowPulse)

                        // App logo
                        Image(uiImage: UIImage(named: "Unknown-8") ?? UIImage())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                            .opacity(showSpotlight ? 1 : 0)
                            .animation(.easeIn(duration: 0.8).delay(0.4), value: showSpotlight)
                    }

                        
                }
                .transition(.opacity)
            }

            // HOME transition
            if showHome && isActive {
                ActorHomeView(token: token, user: user, isActive: $isActive)
                    .transition(.opacity)
            }
        }
        .onAppear {
            // Animate spotlight appearance
            withAnimation(.easeInOut(duration: 1.0)) {
                showSpotlight = true
            }
            glowPulse = true

            // Delay before transitioning to home
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                withAnimation(.easeInOut(duration: 1.2)) {
                    showHome = true
                }
            }
        }
        .onChange(of: isActive) { active in
            if !active {
                authToken = nil
                withAnimation(.easeInOut) {
                    showHome = false
                }
                dismiss()
            }
        }
    }
}

