import SwiftUI
@main
struct CastMateApp: App {
    var body: some Scene {
        WindowGroup {
            SplashRouter()
        }
    }
}

struct SplashRouter: View {
    @State private var showSignIn = false
    var body: some View {
        Group {
            if showSignIn {
                SignInView()
            } else {
                WelcomeView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSignIn = true
                }
            }
        }
    }
}
