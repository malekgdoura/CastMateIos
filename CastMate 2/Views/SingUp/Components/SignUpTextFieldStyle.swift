// Views/SignUp/Components/SignUpTextFieldStyle.swift
import SwiftUI

struct SignUpTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding()
            .background(Color.white)
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
}
