import SwiftUI

/// Displays removable tags (used for custom user-added tags)
struct WrapRemovable: View {
    @Binding var tags: [String]
    
    var body: some View {
        FlexibleView(
            availableWidth: UIScreen.main.bounds.width - 48,
            data: tags,
            spacing: 10,
            alignment: .leading
        ) { tag in
            HStack(spacing: 6) {
                Text(tag)
                    .font(.system(size: 16))
                    .padding(.vertical, 8)
                    .padding(.leading, 14)
                Button(action: {
                    withAnimation {
                        tags.removeAll { $0 == tag }
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(.trailing, 8)
                }
            }
            .background(
                Capsule()
                    .fill(Color(red: 0.10, green: 0.07, blue: 0.39))
            )
            .foregroundColor(.white)
        }
    }
}

#Preview {
    WrapRemovable(tags: .constant(["Acting", "Dancing", "Voice Over"]))
        .padding()
}
