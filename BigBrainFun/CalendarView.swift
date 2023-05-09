//
//  CalendarView.swift
//  BigBrainFun
//
//  Created by Ed on 07/04/2023.
//

import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    
    var body: some View {
        VStack {
            HStack {
                Button("<") {
                    currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
                }
                Text("\(currentMonth, formatter: dateFormatter)")
                Button(">") {
                    currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
                }
            }
            .padding(5)
            
            MonthView(selectedDate: $selectedDate, currentMonth: $currentMonth)
                .padding()
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}

struct MonthView: View {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    
    var body: some View {
        VStack {
            WeekdayHeaderView()
            ForEach(monthData, id: \.self) { week in
                HStack(spacing: 0) {
                    ForEach(week, id: \.self) { day in
                        DayView(day: day, selectedDate: $selectedDate, currentMonth: $currentMonth)
                    }
                }
            }
        }
    }
    
    private var monthData: [[Date]] {
        let month = currentMonth
        let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: month))!
        let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startOfMonth))!
        let endOfMonth = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!

        let firstDayOfWeek = Calendar.current.date(byAdding: .day, value: -1 * (Calendar.current.component(.weekday, from: startOfMonth) - 1), to: startOfMonth)!
        let lastDayOfWeek = Calendar.current.date(byAdding: .day, value: (7 - Calendar.current.component(.weekday, from: endOfMonth)), to: endOfMonth)!

        let totalDays = Calendar.current.dateComponents([.day], from: firstDayOfWeek, to: lastDayOfWeek).day! + 1
        let totalWeeks = totalDays / 7 + (totalDays % 7 > 0 ? 1 : 0)

        return (0..<totalWeeks).map { week in
            (0..<7).map { day -> Date in
                let date = Calendar.current.date(byAdding: .day, value: (week * 7) + day, to: firstDayOfWeek)!
                return date
            }
        }
    }
}

struct DayView: View {
    let day: Date
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    @EnvironmentObject var questsManager: QuestsManager
    
    @State private var showQuests = false
    
    var body: some View {
        let numberOfCompletedQuests = getNumberOfCompletedQuests(on: day)
        
        Button(action: {
            selectedDate = day
            showQuests = true
        }) {
            VStack {
                Text("\(Calendar.current.component(.day, from: day))")
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : isInCurrentMonth ? .primary : .secondary)
                
                if numberOfCompletedQuests > 0 {
                    HStack(spacing: 3) {
                        ForEach(0..<min(numberOfCompletedQuests, 3)) { _ in
                            Image(systemName: "circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 7))
                        }
                        if numberOfCompletedQuests > 3 {
                            Text("+\(numberOfCompletedQuests - 3)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.accentColor : Color.clear)
        .sheet(isPresented: $showQuests) {
            QuestsListView(day: day)
                .environmentObject(questsManager)
                .frame(minWidth: 300, minHeight: 400)
        }
    }
    
    private var isInCurrentMonth: Bool {
        Calendar.current.isDate(day, equalTo: currentMonth, toGranularity: .month)
    }
    
    private var isSelected: Bool {
        Calendar.current.isDate(day, equalTo: selectedDate, toGranularity: .day)
    }
    
    private func getNumberOfCompletedQuests(on date: Date) -> Int {
        let allQuests = questsManager.getAllQuests()
        let completedQuests = allQuests.filter { quest in
            if let completionDate = quest.completionDate {
                return Calendar.current.isDate(completionDate, equalTo: date, toGranularity: .day)
            } else {
                return false
            }
        }
        return completedQuests.count
    }
}

struct QuestsListView: View {
    let day: Date
    @EnvironmentObject var questsManager: QuestsManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        let completedQuests = getCompletedQuests(on: day)
        VStack {
            HStack {
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .buttonStyle(CloseButton())
                .padding(.trailing, 16)
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            if completedQuests.isEmpty {
                Text("No completed quests on this day.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List(completedQuests) { quest in
                    HStack {
                        Image(systemName: quest.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(quest.isCompleted ? .green : .secondary)
                            .font(.system(size: 24))
                            .frame(width: 32, height: 32)
                            .padding(.trailing, 8)
                        Text(quest.title)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("+ 100 points")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                .listStyle(SidebarListStyle())
            }
            Spacer()
        }
        .ignoresSafeArea(.all)
    }
    
    private func getCompletedQuests(on date: Date) -> [Quest] {
        let allQuests = questsManager.getAllQuests()
        let completedQuests = allQuests.filter { quest in
            if let completionDate = quest.completionDate {
                return Calendar.current.isDate(completionDate, equalTo: date, toGranularity: .day)
            } else {
                return false
            }
        }
        return completedQuests
    }
}

struct WeekdayHeaderView: View {
    let weekdaySymbols = Calendar.current.shortWeekdaySymbols
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { weekday in
                Text("\(weekday)")
                    .font(.caption2)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
