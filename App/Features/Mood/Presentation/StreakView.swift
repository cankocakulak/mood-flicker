import SwiftUI

/// Gentle streak visualization component
/// Shows streak count with positive messaging, hides after 24h if streak breaks
struct StreakView: View {
    let streakInfo: StreakCalculator.StreakInfo
    
    @State private var isAnimating = false
    
    var body: some View {
        if streakInfo.shouldHide {
            // Hidden - show nothing
            EmptyView()
        } else if !streakInfo.isActive && streakInfo.currentStreak == 0 {
            // No streak yet - show gentle encouragement
            gentleStartView
        } else {
            // Active or paused streak
            streakCard
        }
    }
    
    // MARK: - Views
    
    private var streakCard: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.lg) {
                // Streak icon with flame animation
                streakIcon
                
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    // Streak count
                    Text("\(streakInfo.currentStreak) gün")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(streakInfo.isActive ? .primary : .secondary)
                    
                    // Status message
                    if let message = streakInfo.displayMessage {
                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Status indicator
                statusIndicator
            }
            
            // Last entry info (subtle)
            if let lastDate = streakInfo.lastEntryDate {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    
                    Text("Son kayıt: \(StreakCalculator.timeAgoString(from: lastDate))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    
                    Spacer()
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card)
                .fill(streakInfo.isActive ? streakBackgroundColor : Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card)
                .stroke(streakInfo.isActive ? streakBorderColor : Color.clear, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(streakInfo.accessibilityLabel)
        .onAppear {
            if streakInfo.isActive {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
        }
    }
    
    private var streakIcon: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(streakInfo.isActive ? streakIconBackground : Color(.tertiarySystemFill))
                .frame(width: 56, height: 56)
            
            // Flame icon
            Image(systemName: streakInfo.isActive ? "flame.fill" : "flame")
                .font(.system(size: 28))
                .foregroundStyle(streakInfo.isActive ? streakIconColor : .secondary)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isAnimating)
        }
    }
    
    private var statusIndicator: some View {
        Group {
            if streakInfo.isActive {
                // Active indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    
                    Text("Aktif")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
            } else {
                // Paused indicator
                HStack(spacing: 4) {
                    Image(systemName: "pause.circle")
                        .font(.caption)
                    
                    Text("Durakladı")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var gentleStartView: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            Text("İlk streak'ini başlatmak için bir kayıt yap")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .accessibilityLabel("Henüz streak başlatılmadı. İlk kaydı yaparak başlayabilirsin.")
    }
    
    // MARK: - Colors
    
    private var streakBackgroundColor: Color {
        Color.orange.opacity(0.08)
    }
    
    private var streakBorderColor: Color {
        Color.orange.opacity(0.2)
    }
    
    private var streakIconBackground: Color {
        Color.orange.opacity(0.15)
    }
    
    private var streakIconColor: Color {
        Color.orange
    }
}

// MARK: - Preview

#Preview("Active Streak") {
    StreakView(streakInfo: .active)
        .padding()
}

#Preview("Paused Streak") {
    StreakView(streakInfo: .paused)
        .padding()
}

#Preview("Hidden Streak") {
    StreakView(streakInfo: .hidden)
        .padding()
}

#Preview("Empty Streak") {
    StreakView(streakInfo: .empty)
        .padding()
}