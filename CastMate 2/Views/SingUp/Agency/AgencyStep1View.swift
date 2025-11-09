// Views/SignUp/Agency/AgencyStep1View.swift
import SwiftUI

struct AgencyStep1View: View {
    @Binding var data: AgencySignUpData
    let onNext: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                Text("Create your Agency account").font(.headline)

                TextField("Agency Name", text: $data.agencyName)
                    .textFieldStyle(SignUpTextFieldStyle())
                TextField("Responsible Name", text: $data.responsibleName)
                    .textFieldStyle(SignUpTextFieldStyle())
                TextField("Email", text: $data.email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(SignUpTextFieldStyle())
                SecureField("Password", text: $data.password)
                    .textFieldStyle(SignUpTextFieldStyle())
                TextField("Phone", text: $data.phone)
                    .keyboardType(.phonePad)
                    .textFieldStyle(SignUpTextFieldStyle())
                TextField("Government", text: $data.government)
                    .textFieldStyle(SignUpTextFieldStyle())

                Button(action: onNext) {
                    Text("Next")
                        .foregroundColor(.white).fontWeight(.semibold)
                        .frame(maxWidth: .infinity).padding()
                        .background(Color(red: 0.10, green: 0.07, blue: 0.39))
                        .cornerRadius(25)
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 3)
                }
            }
        }
    }
}
