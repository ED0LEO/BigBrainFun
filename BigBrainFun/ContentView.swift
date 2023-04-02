import SwiftUI

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct GrowingGradButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [.pink, .purple]), startPoint: .leading, endPoint: .trailing))
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .bold()
    }
}

struct InitialView: View{
    @State private var fruits = ["star", "heart", "questionmark"]
    @State private var reel1 = "star"
    @State private var reel2 = "heart"
    @State private var reel3 = "questionmark"
    @State private var isRolling = false
    
    var body: some View{
        
        VStack{
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Enhancer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
            
            Spacer()
                .frame(height: 50)
            
            HStack(spacing: 40) {
                Image(systemName: reel1)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.yellow)
                Image(systemName: reel2)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.pink)
                Image(systemName: reel3)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.green)
            }
            .frame(height: 150)
            Spacer()
                .frame(height: 50)
            Group{
                Button("Roll", action: spinReels)
                    .buttonStyle(GrowingGradButton())
                    .padding()
                    .disabled(isRolling)
                    .opacity(isRolling ? 0.5 : 1)
                    .animation(.easeInOut(duration: 0.3))
                
                Spacer()
                    .frame(height: 50)
            }
            
        }
    }
    
    func spinReels() {
        isRolling = true
        let newReel1 = fruits.randomElement()!
        let newReel2 = fruits.randomElement()!
        let newReel3 = fruits.randomElement()!
        
        withAnimation(.easeInOut(duration: 1)) {
            reel1 = newReel1
            reel2 = newReel2
            reel3 = newReel3
        }
        
        if reel1 == reel2 && reel2 == reel3 {
            print("Match!")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            isRolling = false
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack{
                NavigationLink(destination: InitialView()) {
                    Text("Dash")
                        .padding()
                }
                .buttonStyle(GrowingButton())
                NavigationLink(destination: PlanView()) {
                    Text("Planning")
                        .padding()
                }
                .buttonStyle(GrowingButton())
                NavigationLink(destination: RulesView()) {
                    Text("Guide")
                        .padding()
                }
                .buttonStyle(GrowingButton())
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
