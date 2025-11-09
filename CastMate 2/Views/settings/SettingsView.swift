import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let token: String
    let user: UserInfo?
    @Binding var isRootActive: Bool
    @AppStorage("authToken") private var authToken: String?

    var body: some View {
        ZStack(alignment: .top) {
                // Background gradient header
                VStack(spacing: 0) {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.10, green: 0.07, blue: 0.39),
                            Color(red: 0.27, green: 0.23, blue: 0.69)
                        ]),
                        startPoint: .top, endPoint: .bottom
                    )
                    .frame(height: 220)
                    .clipShape(SettingsWaveShape())

                    Spacer(minLength: 0)
                }
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top back button
                    HStack {
                        CustomBackButton {
                            dismiss()
                        }
                        .padding(.leading, 16)
                        .padding(.top, 60)
                        Spacer()
                    }

                    VStack(spacing: 30) {
                        // Profile spotlight
                        VStack(spacing: 0) {
                            ZStack {
                                SpotlightBeams()
                                    .frame(height: 180)

                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "#454690"),
                                                Color(hex: "#0A0054")
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: 130, height: 130)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 55, height: 55)
                                            .foregroundColor(.white)
                                    )
                                    .shadow(radius: 8)
                            }
                        }
                        .padding(.top, 40)

                        // Status selector
                        HStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 14, height: 14)
                            Text("Active")
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 24)

                        // Options
                        VStack(spacing: 14) {
                            NavigationLink(destination: ProfileView(token: token, user: user)) {
                                SettingsRow(icon: "person.fill", label: "My Profile")
                            }
                            .buttonStyle(.plain)

                            SettingsRow(icon: "star.fill", label: "Favorites")
                            SettingsRow(icon: "briefcase.fill", label: "My Portfolio")
                            SettingsRow(icon: "location.fill", label: "Location")
                            SettingsRow(icon: "gearshape.fill", label: "Settings")
                            Button {
                                logout()
                            } label: {
                                SettingsRow(icon: "arrow.uturn.left.circle.fill", label: "Logout", isLogout: true)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 24)

                        Spacer()
                    }
                    .padding(.top, 80)
                }
                Spacer(minLength: 0)
        }
        .navigationBarBackButtonHidden(true)
        .animation(.easeInOut(duration: 0.4), value: UUID())
    }

    private func logout() {
        authToken = nil
        isRootActive = false
        dismiss()
    }
}

// MARK: - Reusable row view
struct SettingsRow: View {
    let icon: String
    let label: String
    var isLogout: Bool = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.black)
                .frame(width: 40)
            Text(label)
                .foregroundColor(.black)
                .font(.headline)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Color(red: 0.10, green: 0.07, blue: 0.39))
                .clipShape(Circle())
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.10, green: 0.07, blue: 0.39),
                    Color(red: 0.27, green: 0.23, blue: 0.69)
                ]),
                startPoint: .leading, endPoint: .trailing
            )
            .opacity(isLogout ? 0.6 : 1.0)
        )
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
    }
}

// MARK: - Spotlight beams
struct SpotlightBeams: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.07),
                    Color(hex: "#0A0054").opacity(1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 160, height: 500)
            .rotationEffect(.degrees(-28))
            .offset(x: -80, y: -100)
            .blur(radius: 4)

            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.07),
                    Color(hex: "#0A0054").opacity(1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 160, height: 500)
            .rotationEffect(.degrees(28))
            .offset(x: 80, y: -100)
            .blur(radius: 4)
        }
    }
}

// MARK: - Wave shape
struct SettingsWaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height * 0.6))
        path.addCurve(
            to: CGPoint(x: rect.width, y: rect.height * 0.3),
            control1: CGPoint(x: rect.width * 0.3, y: rect.height * 0.8),
            control2: CGPoint(x: rect.width * 0.7, y: rect.height * 0.1)
        )
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.closeSubpath()
        return path
    }
}

// MARK: - Color helper
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var int: UInt64 = 0
        scanner.scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
