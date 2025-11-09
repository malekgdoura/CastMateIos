import SwiftUI

/// A reusable picker for choosing from a set of predefined tags or options.
struct WrapPickers: View {
    let allOptions: [String]                  // All possible options to pick from
    @Binding var selectedOptions: Set<String> // The user's selected options
    
    var body: some View {
        FlexibleView(
            availableWidth: UIScreen.main.bounds.width - 48,
            data: allOptions,
            spacing: 8,
            alignment: .leading
        ) { option in
            OptionChip(
                title: option,
                isSelected: selectedOptions.contains(option)
            ) {
                if selectedOptions.contains(option) {
                    selectedOptions.remove(option)
                } else {
                    selectedOptions.insert(option)
                }
            }
        }
    }
}

struct OptionChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Text(title)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                Capsule()
                    .fill(isSelected ? Color(red: 0.10, green: 0.07, blue: 0.39) : Color.gray.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : .black)
            .onTapGesture(perform: onTap)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    WrapPickers(
        allOptions: ["Comedy", "Drama", "Action", "Romance"],
        selectedOptions: .constant(["Drama", "Comedy"])
    )
    .padding()
}
