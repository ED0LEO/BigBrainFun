//
//  BigBrainFunApp.swift
//  BigBrainFun
//
//  Created by Ed on 01/04/2023.
//

import SwiftUI

struct SideButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color: Color.purple.opacity(0.5), radius: 10, x: 0, y: 5)
                }
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.4, blendDuration: 0))
            .rotationEffect(Angle(degrees: configuration.isPressed ? 10 : 0))
            .offset(x: configuration.isPressed ? 30 : 0, y: configuration.isPressed ? 30 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.4, blendDuration: 0))
    }
}

@main
struct BigBrainFunApp: App {
    @State private var showCalendar = false
    let questsManager = QuestsManager()
    
    var body: some Scene {
        WindowGroup {
            VStack {
                ContentView()
                Button(showCalendar ? "Hide Calendar" : "Show Calendar") {
                    showCalendar.toggle()
                }
                .buttonStyle(SideButtonStyle())
                .padding(5)
                
                if showCalendar {
                    CalendarView()
                }
            }
            .environmentObject(questsManager)
        }
    }
}

