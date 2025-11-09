// Views/SignUp/Agency/AgencyStep2View.swift
import SwiftUI

struct AgencyStep2View: View {
    @Binding var data: AgencySignUpData
    let onFinish: () -> Void

    @State private var showLogoPicker = false
    @State private var showDocPicker = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                Text("Details & Documents").font(.headline)

                TextField("Website (optional)", text: $data.website)
                    .keyboardType(.URL)
                    .textFieldStyle(SignUpTextFieldStyle())

                TextField("Description / Agency presentation", text: $data.description, axis: .vertical)
                    .textFieldStyle(SignUpTextFieldStyle())

                Button {
                    showLogoPicker = true
                } label: {
                    HStack {
                        Image(systemName: "photo.fill")
                        Text(data.logo == nil ? "Upload Agency Logo" : "Change Agency Logo")
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.white).cornerRadius(25)
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                }

                Button {
                    showDocPicker = true
                } label: {
                    HStack {
                        Image(systemName: "doc.richtext.fill")
                        Text(data.adminDocumentURL == nil ? "Upload Administrative Document" : "Change Document")
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.white).cornerRadius(25)
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                }

                Button(action: onFinish) {
                    Text("Finish")
                        .foregroundColor(.white).fontWeight(.semibold)
                        .frame(maxWidth: .infinity).padding()
                        .background(Color(red: 0.10, green: 0.07, blue: 0.39))
                        .cornerRadius(25)
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 3)
                }
            }
        }
        .sheet(isPresented: $showLogoPicker) {
            ImagePicker(image: $data.logo)
        }
        .sheet(isPresented: $showDocPicker) {
            DocumentPicker(url: $data.adminDocumentURL)
        }
    }
}
