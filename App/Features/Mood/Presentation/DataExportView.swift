import SwiftData
import SwiftUI

/// View for exporting mood data with format selection and date range filtering
struct DataExportView: View {
    @StateObject private var exportService: DataExportService
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var selectedFormat: ExportFormat = .json
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate: Date = .init()
    @State private var useDateRange: Bool = false
    @State private var entryCount: Int = 0
    @State private var showShareSheet: Bool = false
    @State private var exportedFileURL: URL?
    @State private var showNoDataAlert: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    // MARK: - Initialization

    init(persistenceService: MoodPersistenceService) {
        _exportService = StateObject(wrappedValue: DataExportService(persistenceService: persistenceService))
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Format Selection

                Section {
                    ForEach(ExportFormat.allCases) { format in
                        Button {
                            selectedFormat = format
                        } label: {
                            HStack {
                                Image(systemName: format.iconName)
                                    .foregroundColor(.accentColor)
                                    .frame(width: 24)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(format.displayName)
                                        .font(.body)
                                        .foregroundColor(.primary)

                                    Text(format.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                if selectedFormat == format {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.accentColor)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.secondary.opacity(0.3))
                                }
                            }
                        }
                    }
                } header: {
                    Text("Format Seçimi")
                }

                // MARK: - Date Range

                Section {
                    Toggle("Tarih Aralığı Kullan", isOn: $useDateRange)

                    if useDateRange {
                        DatePicker(
                            "Başlangıç",
                            selection: $startDate,
                            displayedComponents: [.date])

                        DatePicker(
                            "Bitiş",
                            selection: $endDate,
                            displayedComponents: [.date])
                    }
                } header: {
                    Text("Tarih Aralığı")
                } footer: {
                    if useDateRange {
                        Text("Belirli bir dönemdeki kayıtları dışa aktarın.")
                    } else {
                        Text("Tüm kayıtları dışa aktarın.")
                    }
                }

                // MARK: - Data Preview

                Section {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.accentColor)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Aktarılacak Kayıt")
                                .font(.body)

                            Text("\(entryCount) kayıt bulundu")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                } header: {
                    Text("Veri Önizleme")
                }

                // MARK: - Export Button

                Section {
                    Button {
                        performExport()
                    } label: {
                        HStack {
                            Spacer()

                            if exportService.isExporting {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.white)
                            } else {
                                Image(systemName: "square.and.arrow.up")
                                Text("Dışa Aktar")
                            }

                            Spacer()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(canExport ? Color.accentColor : Color.gray))
                    }
                    .disabled(!canExport || exportService.isExporting)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
            }
            .navigationTitle("Veri Dışa Aktarım")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = exportedFileURL {
                    ShareSheet(items: [url])
                }
            }
            .alert("Aktarılacak Veri Yok", isPresented: $showNoDataAlert) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text("Dışa aktarılacak mood kaydı bulunamadı. Önce birkaç kayıt oluşturun.")
            }
            .alert("Hata", isPresented: $showErrorAlert) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .task {
                await loadEntryCount()
            }
            .onChange(of: useDateRange) { _ in
                Task {
                    await loadEntryCount()
                }
            }
            .onChange(of: startDate) { _ in
                if useDateRange {
                    Task {
                        await loadEntryCount()
                    }
                }
            }
            .onChange(of: endDate) { _ in
                if useDateRange {
                    Task {
                        await loadEntryCount()
                    }
                }
            }
        }
    }

    // MARK: - Helper Properties

    private var canExport: Bool {
        entryCount > 0 && !exportService.isExporting
    }

    // MARK: - Helper Methods

    private func loadEntryCount() async {
        if useDateRange {
            do {
                let entries = try await exportService.fetchEntriesForDateRange(start: startDate, end: endDate)
                entryCount = entries.count
            } catch {
                entryCount = 0
            }
        } else {
            entryCount = await exportService.getEntryCount()
        }
    }

    private func performExport() {
        Task {
            // Check if there's data to export
            let hasData = await exportService.hasDataToExport()
            guard hasData else {
                showNoDataAlert = true
                return
            }

            do {
                let fileURL: URL = if useDateRange {
                    try await exportService.exportEntries(
                        format: selectedFormat,
                        startDate: startDate,
                        endDate: endDate)
                } else {
                    try await exportService.exportEntries(format: selectedFormat)
                }

                exportedFileURL = fileURL
                showShareSheet = true
            } catch let error as DataExportError {
                errorMessage = error.failureReason ?? error.localizedDescription
                showErrorAlert = true
            } catch {
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: items,
            applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    DataExportView(persistenceService: MoodPersistenceService.preview())
}
