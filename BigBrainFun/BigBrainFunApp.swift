//
//  BigBrainFunApp.swift
//  BigBrainFun
//
//  Created by Ed on 01/04/2023.
//

import SwiftUI

class Points: ObservableObject {
    @Published var points: Int {
        didSet {
            savePoints()
        }
    }
    
    init() {
        self.points = UserDefaults.standard.integer(forKey: "points")
    }
    
    func savePoints() {
        UserDefaults.standard.set(points, forKey: "points")
    }
}

@main
struct BigBrainFunApp: App {
    @State private var showCalendar = false
    let questsManager = QuestsManager()
    let points =  Points()
    
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
            .environmentObject(points)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
