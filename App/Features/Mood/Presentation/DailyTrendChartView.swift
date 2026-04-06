import Charts
import Combine
import SwiftData
import SwiftUI

/// View model for daily trend chart data
@MainActor
class DailyTrendChartViewModel: ObservableObject {
    @Published var entries: [MoodEntry] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let persistenceService: MoodPersistenceService

    init(persistenceService: MoodPersistenceService) {
        self.persistenceService = persistenceService
    }

    /// Loads mood entries from the last 24 hours
    func loadDailyEntries() async {
        isLoading = true
        error = nil

        do {
            // Fetch entries from last 1 day (24 hours)
            entries = try await persistenceService.fetchEntriesFromLastDays(1)
        } catch {
            self.error = error
        }

        isLoading = false
    }

    /// Groups entries by hour for the bar chart
    var hourlyData: [HourlyMoodData] {
        let calendar = Calendar.current
        let now = Date()
        let twentyFourHoursAgo = calendar.date(byAdding: .hour, value: -24, to: now) ?? now

        // Create all 24 hour slots (even if empty)
        var data: [HourlyMoodData] = []

        for hourOffset in 0 ..< 24 {
            guard let hourDate = calendar.date(byAdding: .hour, value: -hourOffset, to: now) else { continue }
            let hour = calendar.component(.hour, from: hourDate)

            // Find entries for this hour
            let hourStart = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: hourDate) ?? hourDate
            let hourEnd = calendar.date(byAdding: .hour, value: 1, to: hourStart) ?? hourDate

            let hourEntries = entries.filter { entry in
                entry.timestamp >= hourStart && entry.timestamp < hourEnd
            }

            // Calculate average mood score for this hour
            let avgScore = hourEntries.isEmpty ? nil : Double(hourEntries.reduce(0) { $0 + $1.moodScore }) / Double(hourEntries.count)

            data.append(HourlyMoodData(
                hour: hour,
                displayHour: formatHour(hour),
                entryCount: hourEntries.count,
                averageMoodScore: avgScore,
                entries: hourEntries))
        }

        // Reverse to show oldest to newest (left to right)
        return data.reversed()
    }

    /// Total number of entries in the last 24 hours
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

    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        var components = DateComponents()
        components.hour = hour
        components.minute = 0

        guard let date = Calendar.current.date(from: components) else {
            return "\(hour):00"
        }

        return formatter.string(from: date)
    }
}

/// Data structure for hourly mood aggregation
struct HourlyMoodData: Identifiable {
    let id = UUID()
    let hour: Int
    let displayHour: String
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
}

/// Daily trend chart view showing last 24 hours mood distribution
struct DailyTrendChartView: View {
    @StateObject private var viewModel: DailyTrendChartViewModel
    @State private var selectedHour: HourlyMoodData?

    init(persistenceService: MoodPersistenceService) {
        _viewModel = StateObject(wrappedValue: DailyTrendChartViewModel(persistenceService: persistenceService))
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Summary cards
            summaryCards

            // Chart
            chartView
                .frame(height: 200)

            // Selected hour details
            if let selected = selectedHour, selected.entryCount > 0 {
                hourDetailView(for: selected)
            }
        }
        .padding()
        .task {
            await viewModel.loadDailyEntries()
        }
        .refreshable {
            await viewModel.loadDailyEntries()
        }
    }

    private var summaryCards: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Total entries card
            SummaryCard(
                title: "Kayıt",
                value: "\(viewModel.totalEntries)",
                subtitle: "Son 24 saat",
                icon: "chart.bar.fill",
                color: .blue)

            // Average mood card
            if let avgScore = viewModel.averageMoodScore {
                SummaryCard(
                    title: "Ortalama",
                    value: String(format: "%.1f", avgScore),
                    subtitle: moodDescription(for: avgScore),
                    icon: "face.smiling.fill",
                    color: moodColor(for: avgScore))
            } else {
                SummaryCard(
                    title: "Ortalama",
                    value: "-",
                    subtitle: "Veri yok",
                    icon: "face.smiling.fill",
                    color: .gray)
            }

            // Dominant mood card
            if let dominantEmoji = viewModel.dominantMoodEmoji {
                SummaryCard(
                    title: "Sık Görülen",
                    value: dominantEmoji,
                    subtitle: "Ruh hali",
                    icon: "heart.fill",
                    color: .pink)
            } else {
                SummaryCard(
                    title: "Sık Görülen",
                    value: "-",
                    subtitle: "Veri yok",
                    icon: "heart.fill",
                    color: .gray)
            }
        }
    }

    private var chartView: some View {
        Chart(viewModel.hourlyData) { hourData in
            BarMark(
                x: .value("Saat", hourData.displayHour),
                y: .value("Kayıt", hourData.entryCount))
                .foregroundStyle(hourData.moodColor)
                .cornerRadius(4)
                .opacity(selectedHour?.id == hourData.id ? 1.0 : 0.8)
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 6)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let hourStr = value.as(String.self) {
                        Text(hourStr)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartBackground { chartProxy in
            GeometryReader { _ in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        if let hour = chartProxy.value(atX: location.x, as: String.self) {
                            selectedHour = viewModel.hourlyData.first { $0.displayHour == hour }
                        }
                    }
            }
        }
        .accessibilityLabel("Günlük trend grafiği")
        .accessibilityValue("\(viewModel.totalEntries) kayıt, son 24 saat")
    }

    private func hourDetailView(for hourData: HourlyMoodData) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("\(hourData.displayHour) - \(hourData.entryCount) kayıt")
                .font(.headline)

            ForEach(hourData.entries.prefix(3)) { entry in
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
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(AppTheme.CornerRadius.md)
    }

    private func moodDescription(for score: Double) -> String {
        switch Int(score.rounded()) {
        case 5: "Çok iyi"
        case 4: "İyi"
        case 3: "Orta"
        case 2: "Düşük"
        case 1: "Zor"
        default: "Bilinmiyor"
        }
    }

    private func moodColor(for score: Double) -> Color {
        switch Int(score.rounded()) {
        case 5: .green
        case 4: .mint
        case 3: .yellow
        case 2: .orange
        case 1: .red
        default: .gray
        }
    }
}

/// Reusable summary card component
struct SummaryCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(AppTheme.CornerRadius.md)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview("Daily Trend Chart - With Data") {
    let service = MoodPersistenceService.preview()

    // Add sample data
    Task {
        _ = try? await service.saveMoodEntry(
            moodOption: .happy,
            intensityLevel: .high,
            tags: ["enerjik"])
        _ = try? await service.saveMoodEntry(
            moodOption: .sad,
            intensityLevel: .medium,
            tags: ["yorgun"])
    }

    return DailyTrendChartView(persistenceService: service)
        .padding()
}

#Preview("Daily Trend Chart - Empty") {
    let service = MoodPersistenceService.preview()
    return DailyTrendChartView(persistenceService: service)
        .padding()
}
