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
                    
                    // All ranks
                    VStack(alignment: .leading, spacing: 0) {
                        Text("All Ranks")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.bottom, 12)
                        
                        ForEach(AttendanceStore.levels, id: \.name) { level in
                            let isUnlocked = attendance.score >= level.minEvents
                            let isCurrent = level.name == attendance.currentLevel.name
                            
                            HStack(spacing: 16) {
                                Text(level.emoji)
                                    .font(.title2)
                                    .opacity(isUnlocked ? 1 : 0.3)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(level.name)
                                        .font(.body.weight(isCurrent ? .semibold : .regular))
                                        .foregroundStyle(isUnlocked ? .primary : .secondary)
                                    
                                    Text("\(level.minEvents)+ events")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                if isCurrent {
                                    Text("YOU")
                                        .font(.caption.bold())
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(level.color, in: Capsule())
                                } else if isUnlocked {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.green)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .background(isCurrent ? attendance.currentLevel.color.opacity(0.1) : Color.clear)
                            
                            if level.name != AttendanceStore.levels.last?.name {
                                Divider()
                                    .padding(.leading, 60)
                            }
                        }
                    }
                    .padding(.top, 20)
                    
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
