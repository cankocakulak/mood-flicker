import SwiftUI
import SwiftData
import Charts

/// View model for weekly trend chart data
@MainActor
class WeeklyTrendChartViewModel: ObservableObject {
    @Published var entries: [MoodEntry] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let persistenceService: MoodPersistenceService
    
    init(persistenceService: MoodPersistenceService) {
        self.persistenceService = persistenceService
    }
    
    /// Loads mood entries from the last 7 days
    func loadWeeklyEntries() async {
        isLoading = true
        error = nil
        
        do {
            // Fetch entries from last 7 days
            entries = try await persistenceService.fetchEntriesFromLastDays(7)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    /// Groups entries by day for the line chart
    var dailyData: [DailyMoodData] {
        let calendar = Calendar.current
        let now = Date()
        
        // Create all 7 day slots (even if empty)
        var data: [DailyMoodData] = []
        
        for dayOffset in (0..<7).reversed() {
            guard let dayDate = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
            let startOfDay = calendar.startOfDay(for: dayDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
            
            // Find entries for this day
            let dayEntries = entries.filter { entry in
                entry.timestamp >= startOfDay && entry.timestamp < endOfDay
            }
            
            // Calculate average mood score for this day
            let avgScore = dayEntries.isEmpty ? nil : Double(dayEntries.reduce(0) { $0 + $1.moodScore }) / Double(dayEntries.count)
            
            data.append(DailyMoodData(
                date: dayDate,
                dayName: formatDayName(dayDate),
                dayNumber: calendar.component(.day, from: dayDate),
                entryCount: dayEntries.count,
                averageMoodScore: avgScore,
                entries: dayEntries
            ))
        }
        
        return data
    }
    
    /// Total number of entries in the last 7 days
    var totalEntries: Int {
        entries.count
    }
    
    /// Average mood score across all entries
    var averageMoodScore: Double? {
        guard !entries.isEmpty else { return nil }
        return Double(entries.reduce(0) { $0 + $1.moodScore }) / Double(entries.count)
    }
    
    /// Returns the dominant mood emoji based on entry count
    var dominantMoodEmoji: String? {
        guard !entries.isEmpty else { return nil }
        
        let moodCounts = entries.reduce(into: [:]) { counts, entry in
            counts[entry.emoji, default: 0] += 1
        }
        
        return moodCounts.max(by: { $0.value < $1.value })?.key
    }
    
    /// Returns the day with the highest average mood
    var bestDay: DailyMoodData? {
        dailyData.filter { $0.averageMoodScore != nil }.max(by: { $0.averageMoodScore! < $1.averageMoodScore! })
    }
    
    /// Returns the day with the lowest average mood
    var worstDay: DailyMoodData? {
        dailyData.filter { $0.averageMoodScore != nil }.min(by: { $0.averageMoodScore! < $1.averageMoodScore! })
    }
    
    private func formatDayName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

/// Data structure for daily mood aggregation
struct DailyMoodData: Identifiable {
    let id = UUID()
    let date: Date
    let dayName: String
    let dayNumber: Int
    let entryCount: Int
    let averageMoodScore: Double?
    let entries: [MoodEntry]
    
    /// Returns a color based on the average mood score
    var moodColor: Color {
        guard let score = averageMoodScore else { return .gray.opacity(0.3) }
        switch Int(score.rounded()) {
        case 5: return .green
        case 4: return .mint
        case 3: return .yellow
        case 2: return .orange
        case 1: return .red
        default: return .gray
        }
    }
    
    /// Returns the emoji representing the average mood
    var moodEmoji: String {
        guard let score = averageMoodScore else { return "−" }
        switch Int(score.rounded()) {
        case 5: return "😊"
        case 4: return "🙂"
        case 3: return "😐"
        case 2: return "😔"
        case 1: return "😤"
        default: return "−"
        }
    }
}

/// Weekly trend chart view showing 7-day mood averages
struct WeeklyTrendChartView: View {
    @StateObject private var viewModel: WeeklyTrendChartViewModel
    @State private var selectedDay: DailyMoodData?
    
    init(persistenceService: MoodPersistenceService) {
        _viewModel = StateObject(wrappedValue: WeeklyTrendChartViewModel(persistenceService: persistenceService))
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Summary cards
            summaryCards
            
            // Chart
            chartView
                .frame(height: 220)
            
            // Selected day details
            if let selected = selectedDay, selected.entryCount > 0 {
                dayDetailView(for: selected)
            }
            
            // Weekly insights
            weeklyInsightsView
        }
        .padding()
        .task {
            await viewModel.loadWeeklyEntries()
        }
        .refreshable {
            await viewModel.loadWeeklyEntries()
        }
    }
    
    private var summaryCards: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Total entries card
            SummaryCard(
                title: "Toplam",
                value: "\(viewModel.totalEntries)",
                subtitle: "Son 7 gün",
                icon: "chart.bar.fill",
                color: .blue
            )
            
            // Average mood card
            if let avgScore = viewModel.averageMoodScore {
                SummaryCard(
                    title: "Ortalama",
                    value: String(format: "%.1f", avgScore),
                    subtitle: moodDescription(for: avgScore),
                    icon: "face.smiling.fill",
                    color: moodColor(for: avgScore)
                )
            } else {
                SummaryCard(
                    title: "Ortalama",
                    value: "−",
                    subtitle: "Veri yok",
                    icon: "face.smiling.fill",
                    color: .gray
                )
            }
            
            // Dominant mood card
            if let dominantEmoji = viewModel.dominantMoodEmoji {
                SummaryCard(
                    title: "Sık Görülen",
                    value: dominantEmoji,
                    subtitle: "Ruh hali",
                    icon: "heart.fill",
                    color: .pink
                )
            } else {
                SummaryCard(
                    title: "Sık Görülen",
                    value: "−",
                    subtitle: "Veri yok",
                    icon: "heart.fill",
                    color: .gray
                )
            }
        }
    }
    
    private var chartView: some View {
        Chart(viewModel.dailyData) { dayData in
            // Line mark for the trend
            LineMark(
                x: .value("Gün", dayData.dayName),
                y: .value("Ortalama", dayData.averageMoodScore ?? 0)
            )
            .foregroundStyle(.blue.opacity(0.6))
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            
            // Area mark for visual fill
            AreaMark(
                x: .value("Gün", dayData.dayName),
                y: .value("Ortalama", dayData.averageMoodScore ?? 0)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue.opacity(0.3), .blue.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // Point marks for each day
            PointMark(
                x: .value("Gün", dayData.dayName),
                y: .value("Ortalama", dayData.averageMoodScore ?? 0)
            )
            .foregroundStyle(dayData.moodColor)
            .symbolSize(dayData.entryCount > 0 ? 100 : 0)
            
            // Show emoji as annotation for days with data
            if dayData.entryCount > 0 {
                RuleMark(
                    x: .value("Gün", dayData.dayName)
                )
                .foregroundStyle(.clear)
                .annotation(position: .top) {
                    Text(dayData.moodEmoji)
                        .font(.title3)
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let dayName = value.as(String.self) {
                        Text(dayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: [1, 2, 3, 4, 5]) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let score = value.as(Int.self) {
                        Text(moodLabel(for: score))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .chartYScale(domain: 0.5...5.5)
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        if let dayName = chartProxy.value(atX: location.x, as: String.self) {
                            selectedDay = viewModel.dailyData.first { $0.dayName == dayName }
                        }
                    }
            }
        }
        .accessibilityLabel("Haftalık trend grafiği")
        .accessibilityValue("\(viewModel.totalEntries) kayıt, son 7 gün")
    }
    
    private var weeklyInsightsView: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("Haftalık Özet")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: AppTheme.Spacing.md) {
                // Best day
                if let bestDay = viewModel.bestDay {
                    InsightCard(
                        title: "En İyi Gün",
                        value: bestDay.dayName,
                        subtitle: bestDay.moodEmoji,
                        color: .green
                    )
                }
                
                // Worst day
                if let worstDay = viewModel.worstDay, worstDay.date != viewModel.bestDay?.date {
                    InsightCard(
                        title: "En Zor Gün",
                        value: worstDay.dayName,
                        subtitle: worstDay.moodEmoji,
                        color: .orange
                    )
                }
                
                // Most active day
                if let mostActiveDay = viewModel.dailyData.max(by: { $0.entryCount < $1.entryCount }), mostActiveDay.entryCount > 0 {
                    InsightCard(
                        title: "En Aktif Gün",
                        value: mostActiveDay.dayName,
                        subtitle: "\(mostActiveDay.entryCount) kayıt",
                        color: .blue
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func dayDetailView(for dayData: DailyMoodData) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Text("\(dayData.dayName), \(dayData.dayNumber)")
                    .font(.headline)
                
                Spacer()
                
                Text(dayData.moodEmoji)
                    .font(.title2)
                
                if let avgScore = dayData.averageMoodScore {
                    Text(String(format: "%.1f", avgScore))
                        .font(.headline)
                        .foregroundColor(dayData.moodColor)
                }
            }
            
            Text("\(dayData.entryCount) kayıt")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
            
            ForEach(dayData.entries.prefix(3)) { entry in
                HStack {
                    Text(entry.emoji)
                    Text(entry.formattedTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if !entry.tags.isEmpty {
                        Text(entry.tags.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            if dayData.entries.count > 3 {
                Text("+\(dayData.entries.count - 3) kayıt daha")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(AppTheme.CornerRadius.md)
    }
    
    private func moodDescription(for score: Double) -> String {
        switch Int(score.rounded()) {
        case 5: return "Çok iyi"
        case 4: return "İyi"
        case 3: return "Orta"
        case 2: return "Düşük"
        case 1: return "Zor"
        default: return "Bilinmiyor"
        }
    }
    
    private func moodColor(for score: Double) -> Color {
        switch Int(score.rounded()) {
        case 5: return .green
        case 4: return .mint
        case 3: return .yellow
        case 2: return .orange
        case 1: return .red
        default: return .gray
        }
    }
    
    private func moodLabel(for score: Int) -> String {
        switch score {
        case 1: return "😤"
        case 2: return "😔"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😊"
        default: return ""
        }
    }
}

/// Reusable insight card component for weekly summary
struct InsightCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(AppTheme.CornerRadius.md)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview("Weekly Trend Chart - With Data") {
    let service = MoodPersistenceService.preview()
    
    // Add sample data across multiple days
    Task {
        let calendar = Calendar.current
        let now = Date()
        
        // Day 1 (today) - happy
        _ = try? await service.saveMoodEntry(
            moodOption: .happy,
            intensityLevel: .high,
            tags: ["enerjik"]
        )
        
        // Day 2 (yesterday) - neutral
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let entry2 = MoodEntry(
            emoji: MoodOption.neutral.rawValue,
            intensity: IntensityLevel.medium.rawValue,
            tags: ["sakin"],
            timestamp: yesterday
        )
        
        // Day 3 - sad
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!
        let entry3 = MoodEntry(
            emoji: MoodOption.sad.rawValue,
            intensity: IntensityLevel.high.rawValue,
            tags: ["yorgun"],
            timestamp: twoDaysAgo
        )
        
        // Day 4 - anxious
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now)!
        let entry4 = MoodEntry(
            emoji: MoodOption.anxious.rawValue,
            intensity: IntensityLevel.medium.rawValue,
            tags: ["anksiyetik"],
            timestamp: threeDaysAgo
        )
        
        // Save additional entries
        _ = try? await service.saveMoodEntry(moodOption: .happy, intensityLevel: .medium, tags: ["sosyal"])
    }
    
    return WeeklyTrendChartView(persistenceService: service)
        .padding()
}

#Preview("Weekly Trend Chart - Empty") {
    let service = MoodPersistenceService.preview()
    return WeeklyTrendChartView(persistenceService: service)
        .padding()
}
