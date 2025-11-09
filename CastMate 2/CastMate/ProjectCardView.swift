import SwiftUI

struct ProjectCard: View {
    var name: String
    var date: String
    var count: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .overlay(
                    Text(name)
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                )
                .frame(height: 54)
            HStack {
                Label(date, systemImage: "person.fill")
                Spacer()
                Label("\(count)", systemImage: "arrow.down.circle")
            }
            .font(.subheadline)
            .padding(.horizontal, 16)
        }
        .padding()
        .background(DS.indigoCard)
        .cornerRadius(22)
    }
}

struct HomeView: View {
    var body: some View {
        VStack {
            GradientHeader(style: .doubleCaps)
                .frame(height: 140)
                .overlay(
                    Text("CastMate")
                        .font(.title.bold())
                        .foregroundColor(.white)
                        .offset(y: 20)
                )

            HStack {
                TextField("Search", text: .constant(""))
                    .padding()
                    .background(Color.white)
                    .cornerRadius(26)
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title2)
            }
            .padding(.horizontal)

            ScrollView {
                VStack(spacing: 12) {
                    ProjectCard(name: "Project Name", date: "10/10/2025", count: 90)
                    ProjectCard(name: "Project Name", date: "5/10/2025", count: 15)
                    ProjectCard(name: "Project Name", date: "28/9/2025", count: 7)
                }
                .padding()
            }
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .top)
    }
}
