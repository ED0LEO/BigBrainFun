import SwiftUI

struct ContentView: View {
    @State private var text = "Next project to accomplish"
    @State private var showingImage = false
    
    var body: some View {
        VStack {
            if showingImage {
                            Image(systemName: "link")
                                .resizable()
                                .frame(width: 100, height: 100)
                        } else {
                            Image(systemName: "questionmark")
                                .resizable()
                                .frame(width: 100, height: 100)
                        }
            TextField("Enter text here", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(action: {
                            showingImage.toggle()
                        }) {
                Text("Play")
                    .padding()
                    .cornerRadius(10)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
