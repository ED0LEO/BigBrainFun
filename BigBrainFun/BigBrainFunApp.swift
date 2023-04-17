//
//  BigBrainFunApp.swift
//  BigBrainFun
//
//  Created by Ed on 01/04/2023.
//

import SwiftUI

class Points: ObservableObject {
    private var points: Int
    
    init() {
        points = 0
    }
    
    func setPoints(newNum: Int) {
        points = newNum
    }
    
    func getPoints() -> Int {
        return points
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
    }
}

