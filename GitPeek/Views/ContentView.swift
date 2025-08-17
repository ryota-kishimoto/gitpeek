import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("GitPeek")
                .font(.title)
                .padding()
            
            Text("Repository Manager")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.vertical)
            
            Text("No repositories added yet")
                .foregroundColor(.secondary)
                .padding()
            
            Spacer()
        }
        .frame(width: 300, height: 400)
    }
}