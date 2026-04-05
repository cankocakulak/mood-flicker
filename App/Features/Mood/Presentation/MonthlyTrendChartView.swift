import SwiftUI
import SwiftData
import Charts

/// View model for monthly trend chart data
@MainActor
class MonthlyTrendChartViewModel: ObservableObject {
    @Published var entries: [MoodEntry] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var currentMonth: Date = Date()
    
    private let persistenceService: MoodPersistenceService
    
    init(persistenceService: MoodPersistenceService) {
        self.persistenceService = persistenceService
    }
    
    /// Loads mood entries for the current displayed month
    func loadMonthlyEntries() async {
        isLoading = true
        error = nil
        
        do {
            // Calculate date range for the current month
            let calendar = Calendar.current
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
            
            entries = try await persistenceService.fetchEntries(from: startOfMonth, to: endOfMonth)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    /// Navigate to previous month
    func goToPreviousMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        Task {
            await loadMonthlyEntries()
        }
    }
    
    /// Navigate to next month
    func goToNextMonth() {
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        // Don't allow navigating to future months
        if nextMonth <= Date() {
            currentMonth = nextMonth
            Task {
                await loadMonthlyEntries()
            }
        }
    }
    
    /// Navigate to current month
    func goToCurrentMonth() {
        currentMonth = Date()
        Task {
            await loadMonthlyEntries()
        }
    }
    
    /// Groups entries by day for the line chart
    var dailyData: [MonthlyDayMoodData] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let numberOfDays = range.count
        
        var data: [MonthlyDayMoodData] = []
        
        for day in 1...numberOfDays {
            guard let dayDate = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else { continue }
            let startOfDay = calendar.startOfDay(for: dayDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
            
            // Find entries for this day
            let dayEntries = entries.filter { entry in
                entry.timestamp >= startOfDay && entry.timestamp < endOfDay
            }
            
            // Calculate average mood score for this day
            let avgScore = dayEntries.isEmpty ? nil : Double(dayEntries.reduce(0) { $0 + $1.moodScore }) / Double(dayEntries.count)
            
            data.append(MonthlyDayMoodData(
                day: day,
                date: dayDate,
                entryCount: dayEntries.count,
                averageMoodScore: avgScore,
                entries: dayEntries
            ))
        }
        
        return data
    }
    
    /// Total number of entries in the current month
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
    
    /// Returns formatted month name (e.g., "Nisan 2026")
    var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: currentMonth).capitalized
    }
    
    /// Check if current month is the current actual month
    var isCurrentMonth: Bool {
        let calendar = Calendar.current
        return calendar.isDate(currentMonth, equalTo: Date(), toGranularity: .month)
    }
    
    /// Check if next month navigation should be disabled
    var isNextMonthDisabled: Bool {
        let calendar = Calendar.current
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        return nextMonth > Date()
    }
}

/// Data structure for monthly day mood aggregation
struct MonthlyDayMoodData: Identifiable {
    let id = UUID()
    let day: Int
    let date: Date
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
    
    /// Formatted day name (e.g., "Pzt")
    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

/// Monthly trend chart view showing daily averages for the current month
struct MonthlyTrendChartView: View {
    @StateObject private var viewModel: MonthlyTrendChartViewModel
    @State private var selectedDay: MonthlyDayMoodData?
    
    init(persistenceService: MoodPersistenceService) {
        _viewModel = StateObject(wrappedValue: MonthlyTrendChartViewModel(persistenceService: persistenceService))
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Month navigation header
            monthNavigationHeader
            
            // Summary cards
            summaryCards
            
            // Chart
            chartView
                .frame(height: 240)
            
            // Selected day details
            if let selected = selectedDay, selected.entryCount > 0 {
                dayDetailView(for: selected)
            }
        }
        .padding()
        .task {
            await viewModel.loadMonthlyEntries()
        }
        .refreshable {
            await viewModel.loadMonthlyEntries()
        }
    }
    
    private var monthNavigationHeader: some View {
        HStack {
            // Previous month button
            Button(action: {
                viewModel.goToPreviousMonth()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Önceki ay")
            
            Spacer()
            
            // Month label
            VStack(spacing: 4) {
                Text(viewModel.formattedMonth)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if !viewModel.isCurrentMonth {
                    Button("Bugüne Dön") {
                        viewModel.goToCurrentMonth()
                    }
                    .font(.caption)
                    .foregroundColor(.accentColor)
                }
            }
            
            Spacer()
            
            // Next month button
            Button(action: {
                viewModel.goToNextMonth()
            }) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(viewModel.isNextMonthDisabled ? .gray : .accentColor)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .disabled(viewModel.isNextMonthDisabled)
            .accessibilityLabel("Sonraki ay")
        }
        .padding(.horizontal)
    }
    
    private var summaryCards: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Total entries card
            SummaryCard(
                title: "Kayıt",
                value: "\(viewModel.totalEntries)",
                subtitle: viewModel.formattedMonth,
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
                x: .value("Gün", dayData.day),
                y: .value("Ortalama", dayData.averageMoodScore ?? 0)
            )
            .foregroundStyle(.blue.opacity(0.6))
            .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            
            // Area mark for visual fill
            AreaMark(
                x: .value("Gün", dayData.day),
                y: .value("Ortalama", dayData.averageMoodScore ?? 0)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue.opacity(0.2), .blue.opacity(0.02)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // Point marks for days with data
            if dayData.entryCount > 0 {
                PointMark(
                    x: .value("Gün", dayData.day),
                    y: .value("Ortalama", dayData.averageMoodScore ?? 0)
                )
                .foregroundStyle(dayData.moodColor)
                .symbolSize(60)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: 5)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let day = value.as(Int.self) {
                        Text("\(day)")
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
                        if let day = chartProxy.value(atX: location.x, as: Int.self) {
                            selectedDay = viewModel.dailyData.first { $0.day == day }
                        }
                    }
            }
        }
        .accessibilityLabel("Aylık trend grafiği")
        .accessibilityValue("\(viewModel.totalEntries) kayıt, \(viewModel.formattedMonth)")
    }
    
    private func dayDetailView(for dayData: MonthlyDayMoodData) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Text("\(dayData.day) \(viewModel.formattedMonth)")
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
            
            ForEach(dayData.entries.prefix(5)) { entry in
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
            
            if dayData.entries.count > 5 {
                Text("+\(dayData.entries.count - 5) kayıt daha")
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

// MARK: - Preview

#Preview("Monthly Trend Chart - With Data") {
    let service = MoodPersistenceService.preview()
    
    // Add sample data across multiple days in current month
    Task {
        let calendar = Calendar.current
        let now = Date()
        
        // Add entries for different days
        for dayOffset in [0, 1, 3, 5, 7, 10, 14, 20] {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
            
            let moods: [MoodOption] = [.happy, .neutral, .sad, .anxious, .angry]
            let mood = moods[dayOffset % moods.count]
            
            let entry = MoodEntry(
                emoji: mood.rawValue,
                intensity: Int.random(in: 1...3),
                tags: ["örnek"],
                timestamp: date
            )
            
            // Save entry via context
            let context = ModelContext(service.modelContext.container)
            context.insert(entry)
            try? context.save()
        }
    }
    
    return MonthlyTrendChartView(persistenceService: service)
        .padding()
}

#Preview("Monthly Trend Chart - Empty") {
    let service = MoodPersistenceService.preview()
    return MonthlyTrendChartView(persistenceService: service)
        .padding()
}