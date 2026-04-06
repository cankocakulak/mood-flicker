import SwiftData
import SwiftUI

/// Time range options for trend views
enum TrendTimeRange: String, CaseIterable, Identifiable {
    case day = "Gün"
    case week = "Hafta"
    case month = "Ay"

    var id: String {
        rawValue
    }

    var accessibilityLabel: String {
        switch self {
        case .day: "Günlük görünüm"
        case .week: "Haftalık görünüm"
        case .month: "Aylık görünüm"
        }
    }
}

/// Main trends view with segmented control for day/week/month
struct TrendsView: View {
    @State private var selectedTimeRange: TrendTimeRange = .day
    /// Same instance as the app / `RootView` — avoids a race where `.task` ran before `onAppear` and never saw a persistence layer.
    private let persistenceService: MoodPersistenceService
    @State private var hasEntries = false
    @State private var isLoading = true
    @State private var streakInfo: StreakCalculator.StreakInfo = .empty
    @State private var allEntries: [MoodEntry] = []

    init(persistenceService: MoodPersistenceService) {
        self.persistenceService = persistenceService
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Time range selector
                timeRangeSelector
                    .padding()

                // Content based on selected time range
                contentView
            }
            .navigationTitle("Trendler")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            .task {
                await checkForEntries()
            }
        }
    }

    private var timeRangeSelector: some View {
        Picker("Zaman Aralığı", selection: $selectedTimeRange) {
            ForEach(TrendTimeRange.allCases) { range in
                Text(range.rawValue)
                    .tag(range)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Zaman aralığı seçici")
    }

    @ViewBuilder
    private var contentView: some View {
        if isLoading {
            loadingView
        } else if !hasEntries {
            emptyStateView
        } else {
            switch selectedTimeRange {
            case .day:
                dailyView
            case .week:
                weeklyView
            case .month:
                monthlyView
            }
        }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Spacer()
        }
    }

    private var emptyStateView: some View {
        ScrollView {
            EmptyTrendsView(onAddEntry: {
                // Navigate to check-in (handled by parent tab view)
            })
            .padding(.top, 60)
        }
    }

    private var dailyView: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Streak card at the top
                StreakView(streakInfo: streakInfo)
                    .padding(.horizontal)

                DailyTrendChartView(persistenceService: persistenceService)
                    .padding(.vertical)
            }
        }
        .refreshable {
            await refreshData()
        }
    }

    private var weeklyView: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Streak card at the top
                StreakView(streakInfo: streakInfo)
                    .padding(.horizontal)

                WeeklyTrendChartView(persistenceService: persistenceService)
                    .padding(.vertical)
            }
        }
        .refreshable {
            await refreshData()
        }
    }

    private var monthlyView: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.lg) {
                // Streak card at the top
                StreakView(streakInfo: streakInfo)
                    .padding(.horizontal)

                MonthlyTrendChartView(persistenceService: persistenceService)
                    .padding(.vertical)
            }
        }
        .refreshable {
            await refreshData()
        }
    }

    private func checkForEntries() async {
        do {
            let entries = try await persistenceService.fetchAllEntries()
            allEntries = entries
            hasEntries = !entries.isEmpty

            // Calculate streak info
            streakInfo = StreakCalculator.calculateStreak(from: entries)
        } catch {
            hasEntries = false
            allEntries = []
            streakInfo = .empty
        }

        isLoading = false
    }

    private func refreshData() async {
        await checkForEntries()
    }
}

// MARK: - Preview

private enum TrendsViewPreviewSupport {
    static func inMemoryContainerWithSampleData() -> ModelContainer? {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        guard let container = try? ModelContainer(for: MoodEntry.self, configurations: config) else { return nil }
        let context = ModelContext(container)
        let sampleEntries = [
            MoodEntry(emoji: "😊", intensity: 2, tags: ["enerjik"], timestamp: Date().addingTimeInterval(-3600)),
            MoodEntry(emoji: "😔", intensity: 1, tags: ["yorgun"], timestamp: Date().addingTimeInterval(-7200)),
            MoodEntry(emoji: "😐", intensity: 2, tags: [], timestamp: Date().addingTimeInterval(-10800))
        ]
        for entry in sampleEntries {
            context.insert(entry)
        }
        return container
    }

    static func emptyInMemoryContainer() -> ModelContainer? {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try? ModelContainer(for: MoodEntry.self, configurations: config)
    }
}

#Preview("Trends View - With Data") {
    Group {
        if let container = TrendsViewPreviewSupport.inMemoryContainerWithSampleData() {
            TrendsView(persistenceService: MoodPersistenceService(modelContainer: container))
                .modelContainer(container)
        } else {
            Text("Preview unavailable")
        }
    }
}

#Preview("Trends View - Empty") {
    Group {
        if let container = TrendsViewPreviewSupport.emptyInMemoryContainer() {
            TrendsView(persistenceService: MoodPersistenceService(modelContainer: container))
                .modelContainer(container)
        } else {
            Text("Preview unavailable")
        }
    }
}
