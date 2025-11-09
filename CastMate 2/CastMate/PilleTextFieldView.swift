import SwiftUI

struct PillTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .frame(height: 52)
        .background(DS.fieldBG)
        .cornerRadius(26)
        .shadow(color: .black.opacity(0.1), radius: 6, y: 4)
    }
}

struct PrimaryButton: View {
    var title: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(DS.indigoDark)
                .cornerRadius(26)
        }
        .shadow(color: .black.opacity(0.2), radius: 6, y: 4)
    }
}
