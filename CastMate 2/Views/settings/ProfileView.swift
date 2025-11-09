import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var appear = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var actorProfile: ActorProfile?
    @State private var currentUser: UserInfo?
    @Environment(\.openURL) private var openURL

    private let token: String
    private let authService = AuthService()

    init(token: String, user: UserInfo?) {
        self.token = token
        _currentUser = State(initialValue: user)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.10, green: 0.07, blue: 0.39),
                    Color(red: 0.22, green: 0.19, blue: 0.59)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    header

                    profileHeader

                    infoSection(title: "Informations générales", items: generalInfoItems)

                    infoSection(title: "Détails personnels", items: personalInfoItems)

                    infoSection(title: "Contact", items: contactInfoItems)

                    infoSection(title: "Expérience", items: experienceInfoItems)

                    interestsSection

                    socialSection

                    cvSection
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }

            if isLoading {
                ProgressView("Chargement du profil...")
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 10)
            }
        }
        .task {
            await loadProfile()
            withAnimation(.easeOut(duration: 0.8)) {
                appear = true
            }
        }
        .alert("Erreur", isPresented: Binding<Bool>(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var header: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.4)) {
                    dismiss()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
            Spacer()
            Text("Mon Profil")
                .font(.title2.bold())
                .foregroundColor(.white)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : -10)
                .animation(.easeOut(duration: 0.5), value: appear)
            Spacer()
            Spacer()
        }
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.white)
                .opacity(appear ? 1 : 0)
                .scaleEffect(appear ? 1 : 0.8)
                .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1), value: appear)

            Text(actorProfileFullName ?? userDisplayName ?? "Utilisateur")
                .font(.title.bold())
                .foregroundColor(.white)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 12)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: appear)

            Text(currentUser?.email ?? "Email non renseigné")
                .foregroundColor(.white.opacity(0.85))
                .font(.subheadline)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 12)
                .animation(.easeOut(duration: 0.6).delay(0.25), value: appear)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.15))
        )
        .padding(.top, 12)
    }

    private func infoSection(title: String, items: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))

            VStack(spacing: 12) {
                ForEach(items.filter { !$0.0.isEmpty }, id: \.0) { item in
                    infoRow(label: item.0, value: item.1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value.isEmpty ? "—" : value)
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .cornerRadius(18)
    }

    private var socialSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Réseaux sociaux")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))

            if let links = actorProfile?.socialLinks {
                socialLinkRow(title: "Instagram", value: links.instagram)
                socialLinkRow(title: "YouTube", value: links.youtube)
                socialLinkRow(title: "TikTok", value: links.tiktok)
            } else {
                infoRow(label: "Aucun réseau renseigné", value: "")
            }
        }
    }

    private func socialLinkRow(title: String, value: String?) -> some View {
        infoRow(label: title, value: value ?? "—")
    }

    private var cvSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Documents")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))

            Button {
                if let stringURL = actorProfile?.cvPdf, let url = URL(string: stringURL) {
                    openURL(url)
                }
            } label: {
                HStack {
                    Image(systemName: "doc.richtext.fill")
                    Text(actorProfile?.cvPdf == nil ? "Aucun CV disponible" : "Ouvrir le CV")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.15))
                .cornerRadius(18)
                .foregroundColor(.white)
            }
            .disabled(actorProfile?.cvPdf == nil)
            .opacity(actorProfile?.cvPdf == nil ? 0.5 : 1)
        }
    }

    private var interestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Centres d’intérêt")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))

            if let interests = actorProfile?.centresInteret, !interests.isEmpty {
                WrapChips(allTags: interests, selectedTags: .constant(Set(interests)))
                    .allowsHitTesting(false)
            } else {
                infoRow(label: "Aucun centre d’intérêt renseigné", value: "")
            }
        }
    }

    private var actorProfileFullName: String? {
        if let profile = actorProfile {
            let components = [profile.prenom, profile.nom].compactMap { $0 }.filter { !$0.isEmpty }
            if !components.isEmpty {
                return components.joined(separator: " ")
            }
        }
        return nil
    }

    private var userDisplayName: String? {
        if let role = currentUser?.role, !role.isEmpty {
            return role.capitalized
        }
        if let type = currentUser?.type, !type.isEmpty {
            return type.capitalized
        }
        return nil
    }

    private var generalInfoItems: [(String, String)] {
        var items: [(String, String)] = []

        if let profile = actorProfile {
            items.append(("Identifiant", profile.id ?? currentUser?.id ?? "—"))
            items.append(("Email", profile.email ?? currentUser?.email ?? "—"))
        } else {
            items.append(("Identifiant", currentUser?.id ?? "—"))
            items.append(("Email", currentUser?.email ?? "—"))
        }

        if let role = currentUser?.role ?? currentUser?.type, !role.isEmpty {
            items.append(("Rôle", role.capitalized))
        }

        return items
    }

    private var personalInfoItems: [(String, String)] {
        return [
            ("Nom", actorProfile?.nom ?? "—"),
            ("Prénom", actorProfile?.prenom ?? "—"),
            ("Âge", actorProfile?.age.map { "\($0)" } ?? "—")
        ]
    }

    private var contactInfoItems: [(String, String)] {
        return [
            ("Téléphone", actorProfile?.tel ?? "—"),
            ("Gouvernorat", actorProfile?.gouvernorat ?? "—")
        ]
    }

    private var experienceInfoItems: [(String, String)] {
        return [
            ("Expérience (ans)", actorProfile?.experience.map { "\($0)" } ?? "—"),
            ("Centres d’intérêt", formatTags(actorProfile?.centresInteret))
        ]
    }

    private func formatTags(_ tags: [String]?) -> String {
        guard let tags, !tags.isEmpty else { return "—" }
        return tags.joined(separator: ", ")
    }

    @MainActor
    private func loadProfile() async {
        isLoading = true
        defer { isLoading = false }

        var candidateIds = Array(Set([currentUser?.acteurId, currentUser?.id].compactMap { $0 }))

        if candidateIds.isEmpty {
            do {
                let fetchedUser = try await authService.fetchCurrentUser(token: token)
                currentUser = fetchedUser
                let newIds = [fetchedUser.acteurId, fetchedUser.id].compactMap { $0 }
                candidateIds.append(contentsOf: newIds)
                candidateIds = Array(Set(candidateIds))
            } catch APIError.requestFailed(let status, _) where status == 404 {
                // Endpoint not available, ignore and continue with existing ids
            } catch {
                errorMessage = error.localizedDescription
                return
            }
        }

        guard !candidateIds.isEmpty else { return }

        var lastError: Error?
        for id in candidateIds {
            do {
                actorProfile = try await authService.fetchActorProfile(id: id, token: token)
                lastError = nil
                break
            } catch {
                lastError = error
            }
        }

        if let lastError {
            if let apiError = lastError as? APIError,
               case .requestFailed(let status, _) = apiError,
               status == 404 {
                // No actor profile yet; leave fields empty without showing alert
                actorProfile = nil
            } else {
                errorMessage = lastError.localizedDescription
            }
        }
    }
}
