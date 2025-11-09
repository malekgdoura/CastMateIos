// Views/SignUp/Components/RoleSelectionView.swift
import SwiftUI

struct RoleSelectionView: View {
    let onActor: () -> Void
    let onAgency: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Sign Up")
                .font(.largeTitle.bold())
                .opacity(1).offset(y: 0)

            Text("Choose your account type")
                .font(.headline).foregroundColor(.gray)
                .padding(.bottom, 10)

            RoleButton(title: "I'm an Actor", systemIcon: "person.fill",
                       color: Color(red: 0.10, green: 0.07, blue: 0.39),
                       action: onActor)

            RoleButton(title: "I'm an Agency", systemIcon: "briefcase.fill",
                       color: Color(red: 0.22, green: 0.19, blue: 0.59),
                       action: onAgency)
        }
    }
}

struct RoleButton: View {
    let title: String
    let systemIcon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemIcon).font(.title2)
                Text(title).fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity).padding()
            .background(color)
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.2), radius: 4, y: 3)
        }
    }
}
