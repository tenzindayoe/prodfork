//
//  ScoreView.swift
//  MacEvents
//
//  Simple, friendly score display
//

import SwiftUI

struct ScoreView: View {
    @EnvironmentObject private var attendance: AttendanceStore
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    // Big friendly number
                    VStack(spacing: 8) {
                        Text("\(attendance.score)")
                            .font(.system(size: 80, weight: .bold, design: .rounded))
                            .foregroundStyle(attendance.currentLevel.color)
                        
                        Text("events attended")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Current level
                    VStack(spacing: 12) {
                        Text(attendance.currentLevel.emoji)
                            .font(.system(size: 60))
                        
                        Text(attendance.currentLevel.name)
                            .font(.title2.bold())
                        
                        Text(attendance.currentLevel.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Progress to next level
                    if let next = attendance.nextLevel {
                        VStack(spacing: 16) {
                            // Simple progress bar
                            VStack(spacing: 8) {
                                ProgressView(value: attendance.progressToNextLevel)
                                    .tint(attendance.currentLevel.color)
                                    .scaleEffect(y: 2)
                                
                                HStack {
                                    Text(attendance.currentLevel.emoji)
                                    Spacer()
                                    Text(next.emoji)
                                }
                                .font(.title3)
                            }
                            .padding(.horizontal, 40)
                            
                            Text("\(attendance.eventsToNextLevel) more to become \(next.name)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        // Max level reached
                        Text("🎉 You've reached the top!")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("My Score")
        }
    }
}

#Preview {
    ScoreView()
        .environmentObject(AttendanceStore())
}
