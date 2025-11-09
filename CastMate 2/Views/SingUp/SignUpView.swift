// Views/SignUp/SignUpView.swift
import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var flow: SignUpFlow = .roleSelection

    // Shared data passed between steps
    @State private var actorData = ActorSignUpData()
    @State private var agencyData = AgencySignUpData()

    @State private var appear = false
    @State private var showSuccess = false
    @State private var isGoingForward = true   // ✅ Track direction of navigation
    @State private var isSubmitting = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    private let authService = AuthService()

    var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Static gradient header
            VStack(spacing: 0) {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.10, green: 0.07, blue: 0.39),
                        Color(red: 0.22, green: 0.19, blue: 0.59)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 220)
                .clipShape(SignUpWaveShape())
                Spacer(minLength: 0)
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Custom back button
                HStack {
                    CustomBackButton {
                        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.85, blendDuration: 0.3)) {
                            isGoingForward = false
                            switch flow {
                            case .roleSelection:
                                dismiss()
                            case .actorStep1:
                                flow = .roleSelection
                            case .actorStep2:
                                flow = .actorStep1
                            case .actorStep3:
                                flow = .actorStep2
                            case .agencyStep1:
                                flow = .roleSelection
                            case .agencyStep2:
                                flow = .agencyStep1
                            }
                        }
                    }
                    .padding(.leading, 16)
                    .padding(.top, 60)
                    Spacer()
                }

                // MARK: - Page content
                ZStack {
                    switch flow {
                    case .roleSelection:
                        RoleSelectionView(
                            onActor: {
                                withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.85, blendDuration: 0.3)) {
                                    isGoingForward = true
                                    flow = .actorStep1
                                }
                            },
                            onAgency: {
                                withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.85, blendDuration: 0.3)) {
                                    isGoingForward = true
                                    flow = .agencyStep1
                                }
                            }
                        )
                        .transition(transitionForDirection())

                    case .actorStep1:
                        ActorStep1View(data: $actorData) {
                            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.85, blendDuration: 0.3)) {
                                isGoingForward = true
                                flow = .actorStep2
                            }
                        }
                        .transition(transitionForDirection())

                    case .actorStep2:
                        ActorStep2View(data: $actorData) {
                            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.85, blendDuration: 0.3)) {
                                isGoingForward = true
                                flow = .actorStep3
                            }
                        }
                        .transition(transitionForDirection())

                    case .actorStep3:
                        ActorStep3View(data: $actorData) {
                            Task { await submitActor() }
                        }
                        .transition(transitionForDirection())

                    case .agencyStep1:
                        AgencyStep1View(data: $agencyData) {
                            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.85, blendDuration: 0.3)) {
                                isGoingForward = true
                                flow = .agencyStep2
                            }
                        }
                        .transition(transitionForDirection())

                    case .agencyStep2:
                        AgencyStep2View(data: $agencyData) {
                            Task { await submitAgency() }
                        }
                        .transition(transitionForDirection())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 120)
                .animation(.easeInOut(duration: 0.4), value: flow)
                .disabled(isSubmitting)

                Spacer(minLength: 0)
            }

            // MARK: - Success overlay
            if showSuccess {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .foregroundColor(Color(red: 0.10, green: 0.07, blue: 0.39))
                        .scaleEffect(showSuccess ? 1.0 : 0.9)
                        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: showSuccess)

                    Text("Account Created!")
                        .font(.title2.bold())

                    Text("You can now log in with your credentials.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button("Continue to Login") {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showSuccess = false
                            dismiss()
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 30)
                    .background(Color(red: 0.10, green: 0.07, blue: 0.39))
                    .cornerRadius(20)
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.45))
                .transition(.opacity.combined(with: .scale))
                .zIndex(1)
            }

            if isSubmitting {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                ProgressView("Envoi en cours...")
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 10)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Erreur", isPresented: $showErrorAlert, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(errorMessage)
        })
    }

    // MARK: - Custom transition helper
    private func transitionForDirection() -> AnyTransition {
        let distance: CGFloat = 60
        let insertion = AnyTransition.opacity
            .combined(with: .offset(x: isGoingForward ? distance : -distance))
        let removal = AnyTransition.opacity
            .combined(with: .offset(x: isGoingForward ? -distance : distance))
        return .asymmetric(insertion: insertion, removal: removal)
    }

    @MainActor
    private func submitActor() async {
        guard !isSubmitting else { return }
        isSubmitting = true

        do {
            try await authService.signupActor(from: actorData)
            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.85, blendDuration: 0.3)) {
                showSuccess = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }

        isSubmitting = false
    }

    @MainActor
    private func submitAgency() async {
        guard !isSubmitting else { return }
        isSubmitting = true

        do {
            try await authService.signupAgency(from: agencyData)
            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.85, blendDuration: 0.3)) {
                showSuccess = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }

        isSubmitting = false
    }
}

// MARK: - Wave shape
struct SignUpWaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: rect.height * 0.6))
        p.addCurve(
            to: CGPoint(x: rect.width, y: rect.height * 0.3),
            control1: CGPoint(x: rect.width * 0.3, y: rect.height * 0.8),
            control2: CGPoint(x: rect.width * 0.7, y: rect.height * 0.1)
        )
        p.addLine(to: CGPoint(x: rect.width, y: 0))
        p.addLine(to: CGPoint(x: 0, y: 0))
        p.closeSubpath()
        return p
    }
}
