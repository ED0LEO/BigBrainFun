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
            .padding()

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

        let totalWeeks = Calendar.current.dateComponents([.weekOfMonth], from: startOfMonth, to: endOfMonth).weekOfMonth ?? 0
        return (0..<totalWeeks).map { week in
            (0..<7).map { day -> Date in
                let date = Calendar.current.date(byAdding: .day, value: (week * 7) + day, to: startOfWeek)!
                return date
            }
        }
    }
}

struct DayView: View {
    let day: Date
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date

    var body: some View {
        Button(action: {
            selectedDate = day
        }) {
            Text("\(Calendar.current.component(.day, from: day))")
                .font(.headline)
                .foregroundColor(isSelected ? .white : isInCurrentMonth ? .primary : .secondary)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.accentColor : Color.clear)
    }

    private var isInCurrentMonth: Bool {
        Calendar.current.isDate(day, equalTo: currentMonth, toGranularity: .month)
    }

    private var isSelected: Bool {
        Calendar.current.isDate(day, equalTo: selectedDate, toGranularity: .day)
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
