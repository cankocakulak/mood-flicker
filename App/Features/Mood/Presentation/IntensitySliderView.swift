import SwiftUI

/// Represents the intensity levels for mood entries
enum IntensityLevel: Int, CaseIterable, Identifiable {
    case low = 1
    case medium = 2
    case high = 3

    var id: Int {
        rawValue
    }

    var displayName: String {
        switch self {
        case .low: "Düşük"
        case .medium: "Orta"
        case .high: "Yüksek"
        }
    }

    var accessibilityLabel: String {
        "Yoğunluk: \(displayName)"
    }

    /// Returns the position as a value between 0.0 and 1.0 for slider
    var sliderValue: Double {
        Double(rawValue - 1) / 2.0
    }

    /// Creates an IntensityLevel from a slider value (0.0 to 1.0)
    static func fromSliderValue(_ value: Double) -> IntensityLevel {
        let normalized = max(0, min(1, value))
        let level = Int(round(normalized * 2)) + 1
        return IntensityLevel(rawValue: level) ?? .medium
    }
}

/// A slider component for selecting mood intensity
/// Features 3 discrete levels with mood-colored track fill and haptic feedback
struct IntensitySliderView: View {
    @Binding var intensity: IntensityLevel
    var moodColor: Color

    @State private var sliderValue: Double = 0.5
    @State private var isDragging: Bool = false

    private let thumbSize: CGFloat = 28
    private let trackHeight: CGFloat = 8

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Label
            labelSection

            // Slider
            sliderSection

            // Level indicators
            levelIndicators
        }
        .padding(.vertical, AppTheme.Spacing.md)
        .onAppear {
            sliderValue = intensity.sliderValue
        }
        .onChange(of: intensity) { _, newValue in
            withAnimation(.easeInOut(duration: 0.2)) {
                sliderValue = newValue.sliderValue
            }
        }
    }

    private var labelSection: some View {
        HStack {
            Text("Yoğunluk")
                .font(.headline)
                .foregroundStyle(.primary)

            Spacer()

            Text(intensity.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(moodColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(moodColor.opacity(0.15)))
        }
    }

    private var sliderSection: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width - thumbSize
            let thumbPosition = CGFloat(sliderValue) * trackWidth + thumbSize / 2

            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: trackHeight / 2)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: trackHeight)

                // Filled track (mood color)
                RoundedRectangle(cornerRadius: trackHeight / 2)
                    .fill(moodColor)
                    .frame(width: thumbPosition, height: trackHeight)
                    .animation(.easeInOut(duration: 0.1), value: sliderValue)

                // Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                    .overlay(
                        Circle()
                            .stroke(moodColor, lineWidth: 2))
                    .scaleEffect(isDragging ? 1.2 : 1.0)
                    .position(
                        x: thumbPosition,
                        y: geometry.size.height / 2)
                    .animation(.easeInOut(duration: 0.15), value: isDragging)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                handleDragChange(value, in: geometry)
                            }
                            .onEnded { _ in
                                handleDragEnd()
                            })
            }
        }
        .frame(height: thumbSize)
        .contentShape(Rectangle())
        .onTapGesture { location in
            handleTap(at: location)
        }
    }

    private var levelIndicators: some View {
        HStack {
            Text("Düşük")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Text("Orta")
                .font(.caption)
                .foregroundStyle(intensity == .medium ? moodColor : .secondary)
                .fontWeight(intensity == .medium ? .medium : .regular)

            Spacer()

            Text("Yüksek")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Gesture Handling

    private func handleDragChange(_ value: DragGesture.Value, in geometry: GeometryProxy) {
        isDragging = true

        let trackWidth = geometry.size.width - thumbSize
        let newPosition = value.location.x - thumbSize / 2
        let normalizedValue = Double(newPosition / trackWidth)

        let newIntensity = IntensityLevel.fromSliderValue(normalizedValue)

        // Only update if intensity level changed
        if newIntensity != intensity {
            HapticManager.shared.intensityChanged()
            intensity = newIntensity
        }

        // Update visual slider value for smooth dragging
        sliderValue = max(0, min(1, normalizedValue))
    }

    private func handleDragEnd() {
        isDragging = false

        // Snap to nearest level
        withAnimation(.easeInOut(duration: 0.2)) {
            sliderValue = intensity.sliderValue
        }
    }

    private func handleTap(at location: CGPoint) {
        let trackWidth: CGFloat = 200 // Approximate, will be calculated from geometry
        let normalizedValue = Double(location.x / trackWidth)
        let newIntensity = IntensityLevel.fromSliderValue(normalizedValue)

        if newIntensity != intensity {
            HapticManager.shared.intensityChanged()

            withAnimation(.easeInOut(duration: 0.2)) {
                intensity = newIntensity
            }
        }
    }
}

// MARK: - Accessibility

extension IntensitySliderView {
    var accessibilityValueText: String {
        "\(intensity.displayName), ayarlanabilir"
    }
}

// MARK: - Preview

#Preview("Intensity Slider - Happy") {
    @Previewable @State var intensity: IntensityLevel = .medium

    VStack {
        IntensitySliderView(intensity: $intensity, moodColor: .green)
            .padding()

        Text("Selected: \(intensity.displayName)")
            .font(.caption)
    }
}

#Preview("Intensity Slider - Sad") {
    @Previewable @State var intensity: IntensityLevel = .low

    VStack {
        IntensitySliderView(intensity: $intensity, moodColor: .blue)
            .padding()

        Text("Selected: \(intensity.displayName)")
            .font(.caption)
    }
}

#Preview("Intensity Slider - Angry") {
    @Previewable @State var intensity: IntensityLevel = .high

    VStack {
        IntensitySliderView(intensity: $intensity, moodColor: .red)
            .padding()

        Text("Selected: \(intensity.displayName)")
            .font(.caption)
    }
}
