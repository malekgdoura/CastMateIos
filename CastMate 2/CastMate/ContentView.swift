import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            WelcomeView() // or whatever screen you want first
        }
    }
}

#Preview {
    ContentView()
}
