import SwiftUI

struct ContentView: View {
    @State private var selection = 0
    @State private var isBackgroundViewEnabled = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isBackgroundViewEnabled {
                    SpinningBackgroundView()
                }
                else {
                    FocusBackgroundView()
                }
                
                ZStack {
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
                        
                        ZStack{
                            let localWidth = geometry.size.width * 0.83
                            let localHeight = geometry.size.height * 0.83
                            Spacer()
                            VideoPlayerView(videoID: "HoFS5moZgAc")
                            
                                .frame(width: min(localWidth, geometry.size.height * 1.77), height: min(localHeight, geometry.size.width / 1.77))
                            Spacer()
                        }
                        .tag(3)
                        .tabItem {
                            Label("VideoTEST", systemImage: "triangle.fill")
                        }
                        
                        BrowserView(tabViewController: TabViewController(url: URL(string: "https://www.google.com")!))
                            .tag(4)
                            .tabItem {
                                Label("Browser", systemImage: "triangle.fill")
                            }
                    }
                    .frame(width: geometry.size.width * 0.99, height: geometry.size.height * 0.9)
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(isBackgroundViewEnabled ? "Focus" : "Fun") {
                                isBackgroundViewEnabled.toggle()
                            }
                            .buttonStyle(SideButtonStyle())
                            .padding(5)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
