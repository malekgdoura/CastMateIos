import SwiftUI
struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isMe: Bool
}

struct ChatView: View {
    @State private var messages: [Message] = [
        .init(text: "Hello, I’m Malek 👋 I’m new here can you fill me in please.", isMe: false),
        .init(text: "welcome with us Malek we are so happy to have you", isMe: true),
        .init(text: "we will show you around", isMe: true),
        .init(text: "Ok, how about these?", isMe: false)
    ]
    @State private var newMessage = ""

    var body: some View {
        VStack {
            GradientHeader(style: .doubleCaps)
                .frame(height: 120)
                .overlay(
                    Text("CastMate")
                        .font(.headline)
                        .foregroundColor(.white)
                        .offset(y: 10)
                )

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(messages) { msg in
                        HStack {
                            if msg.isMe { Spacer() }
                            Text(msg.text)
                                .padding()
                                .background(msg.isMe ? DS.bubbleSelf : DS.bubbleOther)
                                .foregroundColor(msg.isMe ? .white : .black)
                                .cornerRadius(18)
                                .frame(maxWidth: 250, alignment: msg.isMe ? .trailing : .leading)
                            if !msg.isMe { Spacer() }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            HStack {
                TextField("Type a message...", text: $newMessage)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(22)
                Button("Send") { }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(DS.indigoDark)
                    .cornerRadius(22)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.white)
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .top)
    }
}
