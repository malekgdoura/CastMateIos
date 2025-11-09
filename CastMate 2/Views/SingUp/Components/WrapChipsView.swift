import SwiftUI

/// A reusable component that wraps text "chips" into multiple lines.
struct WrapChips: View {
    let allTags: [String]                // All available tags to display
    @Binding var selectedTags: Set<String> // The user's selected tags (Set for uniqueness)
    
    var body: some View {
        FlexibleView(
            availableWidth: UIScreen.main.bounds.width - 48,
            data: allTags,
            spacing: 8,
            alignment: .leading
        ) { tag in
            ChipView(
                tag: tag,
                isSelected: selectedTags.contains(tag)
            ) {
                if selectedTags.contains(tag) {
                    selectedTags.remove(tag)
                } else {
                    selectedTags.insert(tag)
                }
            }
        }
    }
}

struct ChipView: View {
    let tag: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Text(tag)
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

/// A flexible layout that wraps views to the next line as needed.
struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let availableWidth: CGFloat
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    
    @State private var elementsSize: [Data.Element: CGSize] = [:]
    
    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { rowElements in
                HStack(spacing: spacing) {
                    ForEach(rowElements, id: \.self) { element in
                        content(element)
                            .fixedSize()
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            elementsSize[element] = geometry.size
                                        }
                                }
                            )
                    }
                }
            }
        }
    }
    
    private func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRowWidth: CGFloat = 0
        
        for element in data {
            let elementSize = elementsSize[element, default: CGSize(width: availableWidth, height: 1)]
            if currentRowWidth + elementSize.width + spacing > availableWidth {
                rows.append([element])
                currentRowWidth = elementSize.width + spacing
            } else {
                rows[rows.count - 1].append(element)
                currentRowWidth += elementSize.width + spacing
            }
        }
        
        return rows
    }
}

#Preview {
    WrapChips(
        allTags: ["Acting", "Directing", "Dancing", "Singing", "Voice Over"],
        selectedTags: .constant(["Acting", "Dancing"])
    )
    .padding()
}
