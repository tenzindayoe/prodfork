//
//  ScoreView.swift
//  MacEvents
//
//  Vertical filling progress bar showing rank progression
//

import SwiftUI

struct ScoreView: View {
    @EnvironmentObject private var attendance: AttendanceStore
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Score header
                    VStack(spacing: 4) {
                        Text("\(attendance.score)")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundStyle(attendance.currentLevel.color)
                        
                        Text("events attended")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Vertical progress bar
                    verticalProgressBar
                        .padding(.horizontal, 20)
                    
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
    
    // MARK: - Vertical Progress Bar
    
    private var verticalProgressBar: some View {
        let levels = AttendanceStore.levels
        let reversedLevels = Array(levels.reversed())
        let totalLevels = levels.count
        let rowHeight: CGFloat = 80
        let totalHeight = CGFloat(totalLevels) * rowHeight
        
        // Fill based on level index (matches row positions)
        let currentLevelIndex = levels.firstIndex(where: { $0.name == attendance.currentLevel.name }) ?? 0
        let levelsFromBottom = CGFloat(currentLevelIndex + 1)
        let fillHeight = (levelsFromBottom / CGFloat(totalLevels)) * totalHeight
        
        return HStack(alignment: .top, spacing: 16) {
            // The vertical bar
            ZStack(alignment: .bottom) {
                // Background bar (gray)
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemGray4))
                    .frame(width: 10)
                
                // Filled bar (colored gradient)
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            colors: [.green, attendance.currentLevel.color],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 10, height: max(0, fillHeight))
            }
            .frame(height: totalHeight)
            
            // Level labels
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(reversedLevels.enumerated()), id: \.element.name) { index, level in
                    let isUnlocked = attendance.score >= level.minEvents
                    let isCurrent = level.name == attendance.currentLevel.name
                    
                    HStack(spacing: 12) {
                        Text(level.emoji)
                            .font(.title3)
                            .opacity(isUnlocked ? 1 : 0.4)
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text(level.name)
                                .font(isCurrent ? .subheadline.bold() : .subheadline)
                                .foregroundStyle(isUnlocked ? .primary : .tertiary)
                            
                            Text("\(level.minEvents)+ events")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if isCurrent {
                            Circle()
                                .fill(level.color)
                                .frame(width: 10, height: 10)
                        }
                    }
                    .frame(height: rowHeight)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isCurrent ? attendance.currentLevel.color.opacity(0.12) : Color.clear)
                    )
                }
            }
        }
        .frame(height: totalHeight)
    }
}

#Preview {
    ScoreView()
        .environmentObject(AttendanceStore())
}
