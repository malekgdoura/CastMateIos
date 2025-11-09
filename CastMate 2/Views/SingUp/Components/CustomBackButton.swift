import SwiftUI

struct CustomBackButton: View {
    @Environment(\.dismiss) private var dismiss
    /// If nil, it will call `dismiss()`
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            if let action { action() } else { dismiss() }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color(red: 0.10, green: 0.07, blue: 0.39))
                    .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
                Text("Back")
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.10, green: 0.07, blue: 0.39))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            )
        }
        .accessibilityLabel("Back")
    }
}
