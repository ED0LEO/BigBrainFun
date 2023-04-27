import SwiftUI

struct LanguagePickerView: View {
    @Binding var languageCode: String
    
    var body: some View {
        VStack {
            Text("Select a language:")
                .font(.headline)
                .padding(.top)
            Picker(selection: $languageCode, label: Text("Language")) {
                Text("English").tag("en")
                Text("Spanish").tag("es")
                Text("French").tag("fr")
            }
            .pickerStyle(MenuPickerStyle())
        }
        .padding()
    }
}

struct ContentView: View {
    @State private var selection = 0
    @State private var isBackgroundViewEnabled = true
    @State private var isLanguagePickerShowing = false
    @State private var selectedLanguageCode = "en"
    
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
                            
                            Button(action: { isLanguagePickerShowing.toggle() }) {
                                Image(systemName: "globe")
                            }
                            .buttonStyle(SideButtonStyle())
                            .padding(5)
                            .popover(isPresented: $isLanguagePickerShowing) {
                                LanguagePickerView(languageCode: $selectedLanguageCode)
                            }
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
