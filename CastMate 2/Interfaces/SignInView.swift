import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var appear = false
    @State private var showSignInSuccess = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showErrorAlert = false
    @State private var navigateToWelcome = false
    @State private var sessionToken = ""
    @State private var signedInUser: UserInfo?
    @AppStorage("authToken") private var authToken: String?

    private let authService = AuthService()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // ✅ Updated Navigation Destination
                NavigationLink(
                    destination: SplashWelcomeView(token: sessionToken, user: signedInUser),
                    isActive: $navigateToWelcome
                ) {
                    EmptyView()
                }
                .hidden()

                // MARK: - Gradient header behind
                VStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.10, green: 0.07, blue: 0.39),
                            Color(red: 0.22, green: 0.19, blue: 0.59)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 220)
                    .clipShape(SignInWaveShape())
                    Spacer()
                }
                .ignoresSafeArea()

                // MARK: - User icon (animated entry)
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.black.opacity(0.9))
                        .padding(.top, 80)
                        .opacity(appear ? 1 : 0)
                        .scaleEffect(appear ? 1 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appear)
                    Spacer()
                }

                // MARK: - Main content
                ScrollView {
                    VStack(spacing: 20) {
                        // Title
                        Text("Sign In")
                            .font(.largeTitle.bold())
                            .padding(.top, 180)
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 40)
                            .animation(.easeOut(duration: 0.5).delay(0.15), value: appear)

                        // Email field
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(25)
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 40)
                            .animation(.easeOut(duration: 0.5).delay(0.25), value: appear)

                        // Password field
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(25)
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 40)
                            .animation(.easeOut(duration: 0.5).delay(0.3), value: appear)

                        // Forgot password
                        HStack {
                            Spacer()
                            NavigationLink(destination: ForgotPasswordView()) {
                                Text("Forgot your password?")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                                    .underline()
                            }
                        }
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 40)
                        .animation(.easeOut(duration: 0.5).delay(0.35), value: appear)

                        // Sign In Button
                        Button {
                            Task { await login() }
                        } label: {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("Sign In")
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .background(Color(red: 0.10, green: 0.07, blue: 0.39))
                        .cornerRadius(25)
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 3)
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                        .padding(.top, 10)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 40)
                        .animation(.easeOut(duration: 0.5).delay(0.4), value: appear)

                        // OR Divider
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.4))
                            Text("Or")
                                .foregroundColor(.gray)
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.4))
                        }
                        .padding(.vertical, 5)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 40)
                        .animation(.easeOut(duration: 0.5).delay(0.45), value: appear)

                        // MARK: - Social buttons
                        HStack(spacing: 30) {
                            // Gmail
                            Button(action: handleGoogleSignIn) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 0.89, green: 0.23, blue: 0.20))
                                        .frame(width: 50, height: 50)
                                        .shadow(radius: 3)
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 22, weight: .bold))
                                }
                            }

                            // LinkedIn
                            Button(action: {}) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 0.0, green: 0.47, blue: 0.71))
                                        .frame(width: 50, height: 50)
                                        .shadow(radius: 3)
                                    Text("in")
                                        .font(.system(size: 24, weight: .black))
                                        .foregroundColor(.white)
                                }
                            }

                            // Facebook
                            Button(action: {}) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 0.23, green: 0.35, blue: 0.60))
                                        .frame(width: 50, height: 50)
                                        .shadow(radius: 3)
                                    Text("f")
                                        .font(.system(size: 28, weight: .black))
                                        .foregroundColor(.white)
                                        .offset(y: -2)
                                }
                            }
                        }
                        .transition(.scale.combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.4), value: UUID())
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 40)
                        .animation(.easeOut(duration: 0.5).delay(0.5), value: appear)

                        // Sign Up link
                        HStack(spacing: 4) {
                            Text("Don’t have an account?")
                                .foregroundColor(.gray)
                            NavigationLink(destination: SignUpView()) {
                                Text("Sign Up")
                                    .foregroundColor(Color(red: 0.10, green: 0.07, blue: 0.39))
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding(.bottom, 40)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 40)
                        .animation(.easeOut(duration: 0.5).delay(0.55), value: appear)
                    }
                    .padding(.horizontal, 24)
                }

                // MARK: - Loading Overlay
                if isLoading {
                    Color.black.opacity(0.1)
                        .ignoresSafeArea()
                }
            }
            .background(Color.white)
            .onAppear {
                withAnimation(.easeOut(duration: 0.7)) {
                    appear = true
                }
            }
        }
        .alert("Erreur de connexion", isPresented: $showErrorAlert, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(errorMessage)
        })
    }

    // MARK: - LOGIN LOGIC
    @MainActor
    private func login() async {
        guard !isLoading else { return }
        isLoading = true

        do {
            let response = try await authService.login(email: email, password: password)
            guard let token = response.access_token else {
                throw APIError.missingAccessToken
            }
            authToken = token
            signedInUser = response.user
            sessionToken = token

            // ✅ Navigate to splash screen on success
            withAnimation(.easeInOut(duration: 0.4)) {
                navigateToWelcome = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }

        isLoading = false
    }

    // MARK: - Custom wave shape for the header
    struct SignInWaveShape: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: rect.height * 0.35))
            path.addCurve(
                to: CGPoint(x: rect.width, y: rect.height * 0.35),
                control1: CGPoint(x: rect.width * 0.25, y: rect.height * 0.10),
                control2: CGPoint(x: rect.width * 0.75, y: rect.height * 0.60)
            )
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.closeSubpath()
            return path
        }
    }
}

// MARK: - GOOGLE SIGN-IN HANDLER
func handleGoogleSignIn() {
    let clientID = "393337800103-2cdh8p6u7vjhis93uvs2tcg399mih3ig.apps.googleusercontent.com"
    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config

    GIDSignIn.sharedInstance.signIn(withPresenting: UIApplication.rootController) { result, error in
        if let error = error {
            print("❌ Google Sign-In error: \(error.localizedDescription)")
            return
        }
        guard let user = result?.user else { return }
        print("✅ Signed in as: \(user.profile?.email ?? "Unknown Email")")
    }
}

#Preview {
    SignInView()
}
