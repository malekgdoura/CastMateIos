import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var showConfirmation = false
    @State private var appear = false // for entry animation

    var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Gradient header
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.10, green: 0.07, blue: 0.39),
                    Color(red: 0.22, green: 0.19, blue: 0.59)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 220)
            .clipShape(ForgotWaveShape())
            .ignoresSafeArea()

            // MARK: - Main content
            ScrollView {
                VStack(spacing: 20) {
                    Text("Forgot Password")
                        .font(.largeTitle.bold())
                        .padding(.top, 160)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 30)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: appear)

                    Text("Enter your email address and we’ll send you instructions to reset your password.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .font(.system(size: 15))
                        .padding(.horizontal)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: appear)

                    TextField("Email", text: $email)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 20)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: appear)

                    // MARK: - Send Reset Link Button
                    Button {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showConfirmation = true
                        }
                    } label: {
                        Text("Send Reset Link")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.10, green: 0.07, blue: 0.39))
                            .cornerRadius(25)
                            .shadow(color: .black.opacity(0.2), radius: 4, y: 3)
                    }
                    .padding(.top, 10)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: appear)

                    // MARK: - Back to Sign In Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            dismiss()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color(red: 0.10, green: 0.07, blue: 0.39))
                            Text("Back to Sign In")
                                .foregroundColor(Color(red: 0.10, green: 0.07, blue: 0.39))
                                .fontWeight(.semibold)
                        }
                        .padding(.top, 30)
                    }
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.5), value: appear)

                    Spacer()
                }
                .padding(.horizontal, 24)
            }

            // Optional smooth confirmation overlay
            if showConfirmation {
                VStack(spacing: 16) {
                    Image(systemName: "envelope.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .foregroundColor(Color(red: 0.10, green: 0.07, blue: 0.39))
                        .shadow(radius: 5)
                    Text("Email Sent!")
                        .font(.title2.bold())
                    Text("Check your inbox for password reset instructions.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Done") {
                        withAnimation {
                            showConfirmation = false
                            dismiss()
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 30)
                    .background(Color(red: 0.10, green: 0.07, blue: 0.39))
                    .cornerRadius(20)
                    .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.45))
                .transition(.opacity.combined(with: .scale))
                .zIndex(1)
            }
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                CustomBackButton()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appear = true
            }
        }
    }
}

// MARK: - Custom wave shape for header
struct ForgotWaveShape: Shape {
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

#Preview {
    ForgotPasswordView()
}
