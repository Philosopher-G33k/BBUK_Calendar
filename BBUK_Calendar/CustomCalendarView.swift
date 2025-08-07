//
//  CustomCalendarView.swift
//  BBUK_Calendar
//
//  Created by Ishan Malviya on 04/08/25.
//

import SwiftUI

struct CustomCalendarView: View {
    @Binding var isPresented: Bool
    @Binding var selectedDate: Date
    let title: String
    
    @State private var currentMonth: Date
    @State private var showYearPicker = false
    @State private var animatePresentation = false
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    init(isPresented: Binding<Bool>, selectedDate: Binding<Date>, title: String = "Target date") {
        self._isPresented = isPresented
        self._selectedDate = selectedDate
        self.title = title
        self._currentMonth = State(initialValue: selectedDate.wrappedValue)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Color.black.opacity(animatePresentation ? 0.3 : 0.0)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
                            animatePresentation = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                isPresented = false
                            }
                        }
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: animatePresentation)
                
                VStack(spacing: 0) {
                // Header
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
                            animatePresentation = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                isPresented = false
                            }
                        }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .font(.title2)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Month navigation
                HStack {
                    // Tappable month-year label with chevron
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showYearPicker.toggle()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text(dateFormatter.string(from: currentMonth))
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                    
                    Spacer()
                    
                    // Month navigation arrows
                    HStack(spacing: 20) {
                        Button(action: {
                            let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                            if !isPastMonth(previousMonth) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentMonth = previousMonth
                                }
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor({
                                    let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                                    return isPastMonth(previousMonth) ? .gray : .blue
                                }())
                                .font(.title2)
                        }
                        .disabled({
                            let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                            return isPastMonth(previousMonth)
                        }())
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.blue)
                                .font(.title2)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                if showYearPicker {
                    // Year picker - only show current and future years
                    let currentYear = calendar.component(.year, from: Date())
                    let selectedYear = calendar.component(.year, from: currentMonth)
                    let years = Array(currentYear...(currentYear + 20))
                    
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 15) {
                            ForEach(years, id: \.self) { year in
                                Button(action: {
                                    // Preserve the current month and day when changing year
                                    let currentMonthComponent = calendar.component(.month, from: currentMonth)
                                    let currentDayComponent = calendar.component(.day, from: currentMonth)
                                    
                                    var dateComponents = DateComponents()
                                    dateComponents.year = year
                                    dateComponents.month = currentMonthComponent
                                    dateComponents.day = currentDayComponent
                                    
                                    if let newDate = calendar.date(from: dateComponents) {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            currentMonth = newDate
                                            showYearPicker = false
                                        }
                                    }
                                }) {
                                    Text(String(year))
                                        .font(.system(size: 18, weight: .regular))
                                        .foregroundColor(year == selectedYear ? .white : .black)
                                        .frame(width: 60, height: 40)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(year == selectedYear ? Color.blue : Color.clear)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(height: 200)
                    .padding(.bottom, 30)
                } else {
                    // Days of week header
                    HStack {
                        ForEach(["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"], id: \.self) { day in
                            Text(day)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    
                    // Calendar grid
                    let daysInMonth = getDaysInMonth()
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 15) {
                        ForEach(daysInMonth, id: \.self) { date in
                            if let date = date {
                                Button(action: {
                                    if !isPastDate(date) {
                                        selectedDate = date
                                    }
                                }) {
                                    Text("\(calendar.component(.day, from: date))")
                                        .font(.system(size: 22, weight: .regular))
                                        .foregroundColor({
                                            if isPastDate(date) {
                                                return .gray
                                            } else if isSelected(date) {
                                                return .blue
                                            } else {
                                                return .black
                                            }
                                        }())
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle()
                                                .fill(isSelected(date) ? Color.blue.opacity(0.2) : Color.clear)
                                        )
                                }
                                .disabled(isPastDate(date))
                            } else {
                                Text("")
                                    .frame(width: 40, height: 40)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                
                // Confirm button
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
                        animatePresentation = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isPresented = false
                        }
                    }
                }) {
                    Text("Confirm")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 65)
                        .background(Color.red)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 21 + geometry.safeAreaInsets.bottom)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .mask(Rectangle().padding(.bottom, -20))
                .padding(.bottom, -geometry.safeAreaInsets.bottom)
                .offset(y: animatePresentation ? 0 : geometry.size.height)
                .opacity(animatePresentation ? 1.0 : 0.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: animatePresentation)
                .ignoresSafeArea(.container, edges: .bottom)
                .onAppear {
                    // Trigger animation on first launch
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
                            animatePresentation = true
                        }
                    }
                }
            }
        }
    }
    
    private func getDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return []
        }
        
        let firstOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 0
        
        var days: [Date?] = []
        
        // Add empty cells for days before the first day of the month
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add days of the month
        for day in 1...numberOfDaysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    private func isPastDate(_ date: Date) -> Bool {
        let today = Date()
        return calendar.compare(date, to: today, toGranularity: .day) == .orderedAscending
    }
    
    private func isPastMonth(_ date: Date) -> Bool {
        let today = Date()
        return calendar.compare(date, to: today, toGranularity: .month) == .orderedAscending
    }
}

#Preview {
    @State var isPresented = true
    @State var selectedDate = Date()
    
    return CustomCalendarView(isPresented: $isPresented, selectedDate: $selectedDate, title: "Target date")
}
