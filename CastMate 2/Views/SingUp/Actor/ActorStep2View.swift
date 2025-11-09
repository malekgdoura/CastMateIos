// Views/SignUp/Actor/ActorStep2View.swift
import SwiftUI

struct ActorStep2View: View {
    @Binding var data: ActorSignUpData
    let onNext: () -> Void

    @State private var showDocPicker = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                Text("Experience & Socials").font(.headline)

                TextField("Years of Experience", text: $data.yearsOfExperience)
                    .keyboardType(.numberPad)
                    .textFieldStyle(SignUpTextFieldStyle())

                Button {
                    showDocPicker = true
                } label: {
                    HStack {
                        Image(systemName: "doc.fill")
                        Text(data.cvURL == nil ? "Upload CV (PDF)" : "Change CV")
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.white).cornerRadius(25)
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                }

                Group {
                    TextField("Instagram URL", text: $data.instagram)
                        .textFieldStyle(SignUpTextFieldStyle())
                    TextField("TikTok URL", text: $data.tiktok)
                        .textFieldStyle(SignUpTextFieldStyle())
                    TextField("YouTube URL", text: $data.youtube)
                        .textFieldStyle(SignUpTextFieldStyle())
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
        .sheet(isPresented: $showDocPicker) {
            DocumentPicker(url: $data.cvURL) // stub below
        }
    }
}
