import SwiftUI

struct GameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(configuration.isPressed ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

struct LanguagePickerView: View {
    @Binding var languageCode: String
    let languages = ["en", "fr"]
    
    var body: some View {
        VStack {
            Text(NSLocalizedString("Select a language", comment: "Prompt for language selection"))
                .font(.headline)
                .padding(.top, 20)
            
            ForEach(languages, id: \.self) { language in
                Button(action: {
                    languageCode = language
                    LanguageManager.shared.setLanguage(languageCode)
                }) {
                    HStack {
                        Image(systemName: language == "en" ? "globe" : "globe.europe.africa")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20)
                            .foregroundColor(languageCode == language ? .white : .gray)
                            .background(languageCode == language ? Color.blue : Color.gray.opacity(0.1))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            .padding(.horizontal, 8)
                        
                        Text(LocalizedStringKey(language == "en" ? "English" : "Français"))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(languageCode == language ? .blue : .black)
                            .padding(.leading, 10)
                    }
                    .frame(width: 130, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        }
        .padding(.bottom, 20)
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
                                Label(NSLocalizedString("Dash", comment: ""), systemImage: "circle.fill")
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
