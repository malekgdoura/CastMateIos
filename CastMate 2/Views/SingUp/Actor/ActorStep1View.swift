// Views/SignUp/Actor/ActorStep1View.swift
import SwiftUI

struct ActorStep1View: View {
    @Binding var data: ActorSignUpData
    let onNext: () -> Void

    @State private var showImagePicker = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                Text("Create your Actor account").font(.headline)

                HStack(spacing: 12) {
                    TextField("First Name", text: $data.firstName)
                        .textFieldStyle(SignUpTextFieldStyle())
                    TextField("Last Name", text: $data.lastName)
                        .textFieldStyle(SignUpTextFieldStyle())
                }

                TextField("Age", text: $data.age)
                    .keyboardType(.numberPad)
                    .textFieldStyle(SignUpTextFieldStyle())

                TextField("Email", text: $data.email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(SignUpTextFieldStyle())

                SecureField("Password", text: $data.password)
                    .textFieldStyle(SignUpTextFieldStyle())

                TextField("Phone Number", text: $data.phone)
                    .keyboardType(.phonePad)
                    .textFieldStyle(SignUpTextFieldStyle())

                TextField("Government", text: $data.government)
                    .textFieldStyle(SignUpTextFieldStyle())

                // Profile photo
                Button {
                    showImagePicker = true
                } label: {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text(data.profileImage == nil ? "Upload Profile Photo" : "Change Profile Photo")
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.white).cornerRadius(25)
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                }

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
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $data.profileImage) // stub below
        }
    }
}
