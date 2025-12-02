//
//  ScoreView.swift
//  MacEvents
//
//  Displays user's attendance score with animations and Macalester-themed levels
//

import SwiftUI

struct ScoreView: View {
    @EnvironmentObject private var attendance: AttendanceStore
    @State private var animateScore = false
    @State private var animateRing = false
    @State private var showLevelUp = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Hero section with animated ring
                    heroSection
                    
                    // Level info card
                    levelCard
                    
                    // Progress to next level
                    if attendance.nextLevel != nil {
                        progressSection
                    } else {
                        maxLevelBadge
                    }
                    
                    // All levels list
                    allLevelsSection
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [attendance.currentLevel.color.opacity(0.1), Color(.systemBackground)],
                    startPoint: .top,
                    endPoint: .center
                )
            )
            .navigationTitle("My Score")
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    animateScore = true
                }
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    animateRing = true
                }
            }
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        ZStack {
            // Animated background ring
            Circle()
                .stroke(
                    attendance.currentLevel.color.opacity(0.2),
                    lineWidth: 20
                )
                .frame(width: 200, height: 200)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: animateScore ? attendance.progressToNextLevel : 0)
                .stroke(
                    attendance.currentLevel.color,
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.2), value: animateScore)
            
            // Pulsing glow
            Circle()
                .fill(attendance.currentLevel.color.opacity(0.1))
                .frame(width: 160, height: 160)
                .scaleEffect(animateRing ? 1.1 : 1.0)
            
            // Center content
            VStack(spacing: 8) {
                Text(attendance.currentLevel.emoji)
                    .font(.system(size: 50))
                    .scaleEffect(animateScore ? 1.0 : 0.5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animateScore)
                
                Text("\(attendance.score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(attendance.currentLevel.color)
                
                Text("events attended")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Level Card
    
    private var levelCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text(attendance.currentLevel.emoji)
                    .font(.title)
                Text(attendance.currentLevel.name)
                    .font(.title2.bold())
            }
            
            Text(attendance.currentLevel.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(attendance.currentLevel.color.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(attendance.currentLevel.color.opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: - Progress Section
    
    private var progressSection: some View {
        VStack(spacing: 16) {
            if let next = attendance.nextLevel {
                HStack {
                    Text("Next Level:")
                        .foregroundStyle(.secondary)
                    Text("\(next.emoji) \(next.name)")
                        .fontWeight(.semibold)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray5))
                            .frame(height: 20)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [attendance.currentLevel.color, next.color],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * (animateScore ? attendance.progressToNextLevel : 0), height: 20)
                            .animation(.easeOut(duration: 1.0), value: animateScore)
                    }
                }
                .frame(height: 20)
                
                Text("\(attendance.eventsToNextLevel) more events to level up!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Max Level Badge
    
    private var maxLevelBadge: some View {
        VStack(spacing: 12) {
            Text("🎉")
                .font(.system(size: 60))
            
            Text("Maximum Level Achieved!")
                .font(.headline)
            
            Text("You are a true Macalester legend!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.yellow.opacity(0.2), .orange.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
    
    // MARK: - All Levels Section
    
    private var allLevelsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All Levels")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(AttendanceStore.levels, id: \.name) { level in
                levelRow(level)
            }
        }
        .padding(.top, 8)
    }
    
    private func levelRow(_ level: MacLevel) -> some View {
        let isUnlocked = attendance.score >= level.minEvents
        let isCurrent = level.name == attendance.currentLevel.name
        
        return HStack(spacing: 16) {
            // Level emoji/icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? level.color.opacity(0.2) : Color(.systemGray5))
                    .frame(width: 50, height: 50)
                
                if isUnlocked {
                    Text(level.emoji)
                        .font(.title2)
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.secondary)
                }
            }
            
            // Level info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(level.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isUnlocked ? .primary : .secondary)
                    
                    if isCurrent {
                        Text("CURRENT")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(level.color, in: Capsule())
                    }
                }
                
                Text("\(level.minEvents)+ events")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Checkmark for unlocked
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(level.color)
                    .font(.title2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCurrent ? level.color.opacity(0.1) : Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrent ? level.color.opacity(0.5) : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    ScoreView()
        .environmentObject(AttendanceStore())
}

