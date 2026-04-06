import SwiftUI

/// Empty state view for when no mood data is available
struct EmptyTrendsView: View {
    let onAddEntry: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            // Illustration
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 80))
                .foregroundColor(.secondary.opacity(0.5))
                .padding()

            // Title
            Text("Henüz kaydın yok")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            // Description
            Text("İlk adımı atmak için bir emoji seç ve ruh halini kaydetmeye başla.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // CTA Button
            Button(action: onAddEntry) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("İlk Kaydı Yap")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.accentColor)
                .cornerRadius(AppTheme.CornerRadius.md)
            }
            .padding(.horizontal, AppTheme.Spacing.xl)
            .padding(.top, AppTheme.Spacing.md)
        }
        .padding()
        .accessibilityLabel("Henüz kayıt yok")
        .accessibilityHint("İlk kaydı yapmak için butona dokun")
    }
}

// MARK: - Preview

#Preview("Empty Trends View") {
    EmptyTrendsView(onAddEntry: {})
}
