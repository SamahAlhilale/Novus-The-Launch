//
//  CalendarView.swift
//  Novus
//
//  Created by Fai Altayeb on 01/10/2025.
//  Safe, preview-friendly version – correct habit fill behavior + leading days.
//

import SwiftUI

struct Calendar: View {
    @StateObject private var storage = HabitStorageManager.shared
    @State private var currentMonth = Date()
    
    private let calendar = Foundation.Calendar.current
    
    // MARK: - Formatters
    private var monthFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MMMM"
        return f
    }
    
    private var yearFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy"
        return f
    }
    
    // MARK: - Month Info
    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 30
    }
    
    private var firstWeekdayOffset: Int {
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        return calendar.component(.weekday, from: firstOfMonth) - 1 // Sunday = 0
    }
    
    // MARK: - All Day Cells (previous + current month)
    private var dayCells: [Date] {
        var days: [Date] = []
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        
        // Add previous month's trailing days if the month doesn't start on Sunday
        if firstWeekdayOffset > 0 {
            let prevMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)!
            let prevMonthDays = calendar.range(of: .day, in: .month, for: prevMonth)!.count
            let startDay = prevMonthDays - firstWeekdayOffset + 1
            for day in startDay...prevMonthDays {
                if let date = calendar.date(from: DateComponents(year: calendar.component(.year, from: prevMonth),
                                                                 month: calendar.component(.month, from: prevMonth),
                                                                 day: day)) {
                    days.append(date)
                }
            }
        }
        
        // Add current month days
        for day in 1...daysInMonth {
            if let date = calendar.date(from: DateComponents(year: calendar.component(.year, from: currentMonth),
                                                             month: calendar.component(.month, from: currentMonth),
                                                             day: day)) {
                days.append(date)
            }
        }
        
        return days
    }
    
    // MARK: - View
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            // Title
            Text("Calendar")
                .font(.largeTitle.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
            
            // Month Header + Navigation Arrows
            HStack(spacing: 16) {
                Button { changeMonth(by: -1) } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(Color(hex: "4B0082"))
                }
                
                Text("\(monthFormatter.string(from: currentMonth)) \(yearFormatter.string(from: currentMonth))")
                    .font(.title2.weight(.semibold))
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                    .frame(maxWidth: 160, alignment: .center)
                
                Button { changeMonth(by: 1) } label: {
                    Image(systemName: "chevron.right.circle.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(Color(hex: "4B0082"))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 18)
            
            // Weekday Headers
            HStack(spacing: 20) {
                ForEach(["Sun","Mon","Tue","Wed","Thu","Fri","Sat"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color(red: 129/255, green: 127/255, blue: 127/255))
                        .frame(width: 36)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // MARK: - Dynamic Week Rows
            let weeks = stride(from: 0, to: dayCells.count, by: 7).map {
                Array(dayCells.dropFirst($0).prefix(7))
            }
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(weeks.enumerated()), id: \.offset) { index, weekDays in
                    WeekRow(
                        week: index + 1,
                        dates: weekDays,
                        storage: storage,
                        baseColor: weekColor(for: index),
                        currentMonth: currentMonth
                    )
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 100)
    }
    
    // MARK: - Change Month
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    // MARK: - Week Colors
    private func weekColor(for index: Int) -> Color {
        switch index {
        case 0: return Color(red: 25/255, green: 25/255, blue: 112/255)
        case 1: return Color(red: 100/255, green: 149/255, blue: 237/255)
        case 2: return Color(red: 75/255, green: 0/255, blue: 130/255)
        case 3: return Color(red: 251/255, green: 207/255, blue: 79/255)
        default: return Color(red: 25/255, green: 25/255, blue: 112/255)
        }
    }
}

// MARK: - Week Row
struct WeekRow: View {
    let week: Int
    let dates: [Date]
    @ObservedObject var storage: HabitStorageManager
    let baseColor: Color
    let currentMonth: Date
    
    private let calendar = Foundation.Calendar.current
    
    var body: some View {
        let cellWidth: CGFloat = 30
        let spacing: CGFloat = 26
        
        HStack(spacing: spacing) {
            ForEach(dates, id: \.self) { date in
                let day = calendar.component(.day, from: date)
                let isFromCurrentMonth = calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
//                let isDone = isHabitDone(on: date)
                let isDone = isHabitDone(on: date)
                let weekOfCompletion = storage.progress.currentWeek
                let weekColor = Color(hex: "4B0082") // always purple
                let isToday = calendar.isDateInToday(date)
                
                ZStack {
                    if isDone {
                        Circle()
//                            .fill(baseColor)
//                            .frame(width: 32, height: 32)
                        
                            .fill(weekColor)
                            .frame(width: 32, height: 32)
                        
                        
                    } else if isToday {
                        Circle()
                            .stroke(Color(hex: "4B0082"), lineWidth: 2)
                            .frame(width: 32, height: 32)
                    }
                    
                    Text("\(day)")
                        .font(.system(size: 15, weight: .regular))
                        .frame(width: cellWidth, height: 30)
                        .foregroundColor(isFromCurrentMonth
                                         ? (isDone ? .white : .black)
                                         : .gray.opacity(0.4))
                }
            }
        }
        .padding(.top, 4)
        .background(
            Color.gray.opacity(0.15)
                .frame(height: 38)
                .cornerRadius(8)
        )
    }
    
    // MARK: - Safe completion check (preview-safe)
    private func isHabitDone(on date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: date)

        let completed = UserDefaults.standard.array(forKey: "completedDates") as? [String] ?? []
        return completed.contains(key)
    }

}

#Preview {
    Calendar()
}
