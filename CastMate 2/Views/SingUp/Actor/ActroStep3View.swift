// Views/SignUp/Actor/ActorStep3View.swift
import SwiftUI

struct ActorStep3View: View {
    @Binding var data: ActorSignUpData
    let onFinish: () -> Void
    
    // Example interest list — replace with your own
    let allInterests = ["Drama","Comedy","Action","Romance","Horror","Dance","Singing","Theater"]
    
    @State private var newTag = ""
    @State private var suggestedTags = ["Professional", "Beginner", "Stage", "Screen"]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                Text("Interests & Tags").font(.headline)
                
                // Multi-select interests (chips)
                WrapChips(allTags: allInterests, selectedTags: $data.interests)
                
                // Tags (add or pick)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        TextField("Add a tag", text: $newTag)
                            .textFieldStyle(SignUpTextFieldStyle())
                        Button {
                            let t = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !t.isEmpty else { return }
                            data.tags.append(t); newTag = ""
                        } label: {
                            Image(systemName: "plus.circle.fill").font(.title2)
                                .foregroundColor(Color(red: 0.10, green: 0.07, blue: 0.39))
                        }
                    }
                    
                    Text("Suggested")
                        .font(.subheadline).foregroundColor(.gray)
                    
                    // Suggested tags (multi-select as chips) — binds directly to data.tags via Set<->Array bridge
                    WrapPickers(
                        allOptions: suggestedTags,
                        selectedOptions: Binding(
                            get: { Set(data.tags) },
                            set: { data.tags = Array($0) }
                        )
                    )
                    
                    if !data.tags.isEmpty {
                        Text("Your tags").font(.subheadline)
                        // Use the binding-based version of WrapRemovable
                        WrapRemovable(tags: $data.tags)
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
        }
    }
}
