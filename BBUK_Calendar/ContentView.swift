//
//  ContentView.swift
//  BBUK_Calendar
//
//  Created by Ishan Malviya on 02/08/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showCalendar = false
    @State private var selectedDate = Date()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Custom Calendar Demo")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                Text("Selected Date:")
                    .font(.headline)
                
                Text(dateFormatter.string(from: selectedDate))
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
            }
            
            Button(action: {
                showCalendar = true
            }) {
                Text("Set Target Date")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
        .overlay(
            // Custom Calendar Bottom Sheet
            Group {
                if showCalendar {
                    CustomCalendarView(
                        isPresented: $showCalendar,
                        selectedDate: $selectedDate,
                        title: "Target date"
                    )
                }
            }
        )
    }
}

#Preview {
    ContentView()
}
