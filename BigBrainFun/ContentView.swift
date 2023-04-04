import SwiftUI

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color: Color.purple.opacity(0.5), radius: 10, x: 0, y: 5)
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white, lineWidth: 3)
                        .blur(radius: 3)
                        .offset(x: -2, y: -2)
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.purple, lineWidth: 3)
                        .blur(radius: 3)
                        .offset(x: 2, y: 2)
                }
            )
            .foregroundColor(.white)
            .font(.system(size: 32, weight: .semibold))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.4, blendDuration: 0))
    }
}


struct GrowingGradButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(20)
            .background(
                ZStack {
                    AngularGradient(gradient: Gradient(colors: [Color.pink, Color(red: 1, green: 0.65, blue: 0.8)]),
                                    center: .center,
                                    startAngle: .degrees(0),
                                    endAngle: .degrees(configuration.isPressed ? 360 : 0))
                    .opacity(configuration.isPressed ? 0.8 : 1)
                    .blur(radius: configuration.isPressed ? 10 : 0)
                    .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color(red: 1, green: 0.65, blue: 0.8).opacity(0.8), radius: 10, x: 0, y: 5)
                    
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white, lineWidth: 3)
                        .blur(radius: 3)
                        .offset(x: -2, y: -2)
                    
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color(red: 1, green: 0.65, blue: 0.8).opacity(0.8), lineWidth: 3)
                        .blur(radius: 3)
                        .offset(x: 2, y: 2)
                }
            )
            .foregroundColor(.white)
            .font(.system(size: 32, weight: .semibold))
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.spring(response: 0.4, dampingFraction: 0.4, blendDuration: 0))
    }
}


struct ContentView: View {
    @State private var selection = 0

    var body: some View {
        ZStack {
            SpinningBackground()
            Spacer()
            
            TabView(selection: $selection) {
                DashView()
                    .tag(0)
                    .tabItem {
                        Label("Dash", systemImage: "circle.fill")
                    }
                
                PlanView()
                    .tag(1)
                    .tabItem {
                        Label("Quests", systemImage: "square.fill")
                    }
                
                RulesView()
                    .tag(2)
                    .tabItem {
                        Label("Guide", systemImage: "triangle.fill")
                    }
            }
            .frame(maxHeight: 300)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .ignoresSafeArea()
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
