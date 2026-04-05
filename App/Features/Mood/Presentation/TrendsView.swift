import SwiftUI
import SwiftData

/// Time range options for trend views
enum TrendTimeRange: String, CaseIterable, Identifiable {
    case day = "Gün"
    case week = "Hafta"
    case month = "Ay"
    
    var id: String { rawValue }
    
    var accessibilityLabel: String {
        switch self {
        case .day: return "Günlük görünüm"
        case .week: return "Haftalık görünüm"
        case .month: return "Aylık görünüm"
        }
    }
}

/// Main trends view with segmented control for day/week/month
struct TrendsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTimeRange: TrendTimeRange = .day
    @State private var persistenceService: MoodPersistenceService?
    @State private var hasEntries = false
    @State private var isLoading = true
    @State private var streakInfo: StreakCalculator.StreakInfo = .empty
    @State private var allEntries: [MoodEntry] = []
    
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
            .onAppear {
                setupPersistenceService()
            }
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
                
                if let service = persistenceService {
                    DailyTrendChartView(persistenceService: service)
                        .padding(.vertical)
                }
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
                
                if let service = persistenceService {
                    WeeklyTrendChartView(persistenceService: service)
                        .padding(.vertical)
                }
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
                
                if let service = persistenceService {
                    MonthlyTrendChartView(persistenceService: service)
                        .padding(.vertical)
                }
            }
        }
        .refreshable {
            await refreshData()
        }
    }
    
    private func setupPersistenceService() {
        guard persistenceService == nil else { return }
        
        // Get the model container from the environment
        if let container = modelContext.container as? ModelContainer {
            persistenceService = MoodPersistenceService(modelContainer: container)
        }
    }
    
    private func checkForEntries() async {
        guard let service = persistenceService else {
            isLoading = false
            return
        }
        
        do {
            let entries = try await service.fetchAllEntries()
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

#Preview("Trends View - With Data") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MoodEntry.self, configurations: config)
    
    // Add sample data
    let context = ModelContext(container)
    let sampleEntries = [
        MoodEntry(emoji: "😊", intensity: 2, tags: ["enerjik"], timestamp: Date().addingTimeInterval(-3600)),
        MoodEntry(emoji: "😔", intensity: 1, tags: ["yorgun"], timestamp: Date().addingTimeInterval(-7200)),
        MoodEntry(emoji: "😐", intensity: 2, tags: [], timestamp: Date().addingTimeInterval(-10800))
    ]
    
    for entry in sampleEntries {
        context.insert(entry)
    }
    
    return TrendsView()
        .modelContainer(container)
}

#Preview("Trends View - Empty") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MoodEntry.self, configurations: config)
    
    return TrendsView()
        .modelContainer(container)
}