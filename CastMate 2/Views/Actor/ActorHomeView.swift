import SwiftUI

struct ActorHomeView: View {
    let token: String
    let user: UserInfo?
    @Binding var isActive: Bool

    @State private var castings: [CastingSummary] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var searchText = ""

    private let authService = AuthService()

    var filteredCastings: [CastingSummary] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return castings }
        return castings.filter { summary in
            let query = searchText.lowercased()
            let title = summary.titre?.lowercased() ?? ""
            let role = summary.role?.lowercased() ?? ""
            let location = summary.lieu?.lowercased() ?? ""
            return title.contains(query) || role.contains(query) || location.contains(query)
        }
    }

    var body: some View {
        ZStack {
            DS.indigoDark.opacity(0.1)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                header
                searchBar

                if isLoading {
                    ProgressView("Chargement des castings...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredCastings.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(DS.indigoMid)
                        Text("Aucun casting trouvé")
                            .font(.title3.bold())
                            .foregroundColor(DS.textPrimary)
                        Text("Réessayez avec un autre mot-clé ou revenez plus tard.")
                            .font(.subheadline)
                            .foregroundColor(DS.textMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(Array(filteredCastings.enumerated()), id: \.offset) { _, casting in
                                CastingCardView(casting: casting)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                }

                bottomTabs
            }
            .padding(.top, 12)
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden(true)
        .task { await loadCastings() }
        .refreshable { await loadCastings() }
        .alert("Erreur", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: Header
    @ViewBuilder
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Casting")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                if let email = user?.email, !email.isEmpty {
                    Text("Bienvenue \(email)")
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            Spacer()
            Button {
                // Future: open calendar filter
            } label: {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(DS.indigoDark)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(colors: [DS.indigoDark, DS.indigoMid],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
        )
    }

    // MARK: Search Bar
    @ViewBuilder
    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.8))
                TextField("Rechercher un casting", text: $searchText)
                    .foregroundColor(.white)
            }
            .padding()
            .background(DS.indigoMid.opacity(0.9))
            .cornerRadius(18)

            Button {
                // Future filters
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(DS.indigoDark)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    // MARK: Bottom Tabs
    @ViewBuilder
    private var bottomTabs: some View {
        HStack {
            tabButton(title: "Home", systemImage: "house.fill", isActive: true)
            Spacer()
            tabButton(title: "History", systemImage: "chart.bar.fill", isActive: false)
            Spacer()
            NavigationLink {
                SettingsView(token: token, user: user, isRootActive: $isActive)
            } label: {
                tabButton(title: "Settings", systemImage: "gearshape.fill", isActive: false)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
        )
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
    }

    @ViewBuilder
    private func tabButton(title: String, systemImage: String, isActive: Bool) -> some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundColor(isActive ? DS.indigoDark : DS.textMuted)
            Text(title)
                .font(.caption)
                .foregroundColor(isActive ? DS.indigoDark : DS.textMuted)
        }
        .frame(maxWidth: .infinity)
        .scaleEffect(isActive ? 1.05 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isActive)
    }

    // MARK: Load Castings
    @MainActor
    private func loadCastings() async {
        guard !isLoading else { return }
        isLoading = true
        do {
            castings = try await authService.fetchCastings()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
}

// MARK: - CastingCardView
private struct CastingCardView: View {
    let casting: CastingSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(colors: [DS.indigoCard, DS.indigoMid],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                    Image(systemName: "person.3.fill")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(width: 80, height: 80)

                VStack(alignment: .leading, spacing: 6) {
                    Text(casting.titre ?? "Casting")
                        .font(.headline)
                        .foregroundColor(DS.textPrimary)
                        .lineLimit(2)

                    Text(synopsisPreview)
                        .font(.subheadline)
                        .foregroundColor(DS.textMuted)
                        .lineLimit(2)

                    HStack {
                        infoChip(title: "rôle", value: casting.role ?? "—")
                        infoChip(title: "âge", value: ageRange ?? "—")
                        Spacer()
                        Text(casting.remuneration ?? "")
                            .font(.headline)
                            .foregroundColor(DS.indigoDark)
                    }
                }
            }

            HStack {
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(DS.textMuted)
                Spacer()
                Image(systemName: "heart.fill")
                    .foregroundColor(Color.red.opacity(0.8))
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
    }

    // MARK: - Helpers
    private var synopsisPreview: String {
        if let s = casting.synopsis, !s.isEmpty { return s }
        if let d = casting.descriptionRole, !d.isEmpty { return d }
        return "Description non fournie."
    }

    private var formattedDate: String {
        guard let dateString = casting.dateDebut,
              let date = iso8601Formatter.date(from: dateString) else {
            return casting.dateDebut ?? ""
        }
        return displayFormatter.string(from: date)
    }

    private var ageRange: String? {
        if let min = casting.ageMinimum, let max = casting.ageMaximum { return "\(min)-\(max)" }
        if let min = casting.ageMinimum { return "\(min)+" }
        if let max = casting.ageMaximum { return "≤\(max)" }
        return nil
    }

    private var iso8601Formatter: ISO8601DateFormatter {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        return f
    }

    private var displayFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f
    }

    private func infoChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.caption2)
                .foregroundColor(DS.textMuted)
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(DS.textPrimary)
        }
        .padding(8)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(DS.indigoCard, lineWidth: 1)
        )
    }
}
