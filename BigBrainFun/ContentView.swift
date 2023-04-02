import SwiftUI

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(.tint)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .bold()
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

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack{
                Spacer()
                List {
                    NavigationLink(destination: DashView()) {
                        Text("Dash")
                            .padding()
                    }
                    .buttonStyle(GrowingButton())
                    NavigationLink(destination: PlanView()) {
                        Text("Quests")
                            .padding()
                    }
                    .buttonStyle(GrowingButton())
                    NavigationLink(destination: RulesView()) {
                        Text("Guide")
                            .padding()
                    }
                    .buttonStyle(GrowingButton())
                }
                .padding(.vertical)
                .listStyle(SidebarListStyle())
                .frame(height: 300)
                Spacer()
            }
            .navigationTitle("BBF MENU")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
