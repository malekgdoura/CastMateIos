import SwiftUI
struct WelcomeView: View {
    var body: some View {
        ZStack {
            GradientHeader(style: .doubleCaps)
                .frame(height: 200)
            VStack(spacing: 8) {
                Text("Welcome to")
                    .font(.title2)
                    .foregroundStyle(DS.indigoMid)
                Text("CastMate")
                    .font(.largeTitle.bold())
                    .foregroundStyle(DS.indigoMid)
            }
        }
    }
}
