import SwiftUI

struct RecentSection: View {
    let items: [ScanResult]
    let onTap: (ScanResult) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Scan")
                .font(.headline)
                .padding(.horizontal, 16)

            VStack(spacing: 10) {
                ForEach(items.prefix(5)) { r in
                    Button {
                        onTap(r)
                    } label: {
                        HStack(spacing: 12) {
                            Circle()
                                .frame(width: 14, height: 14)
                                .opacity(0.9)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(r.input)
                                    .font(.subheadline).bold()
                                    .lineLimit(1)
                                Text(r.timestamp.formatted(date: .numeric, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            StatusPill(level: r.level)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(background(for: r.level))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(border(for: r.level), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 16)
                    }
                    .buttonStyle(.plain)
                }

                if items.isEmpty {
                    Text("ยังไม่มีประวัติการสแกน")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                }
            }
        }
    }

    private func background(for level: RiskLevel) -> Color {
        switch level {
        case .low: return Color.green.opacity(0.12)
        case .medium: return Color.orange.opacity(0.14)
        case .high: return Color.red.opacity(0.14)
        }
    }

    private func border(for level: RiskLevel) -> Color {
        switch level {
        case .low: return Color.green.opacity(0.35)
        case .medium: return Color.orange.opacity(0.35)
        case .high: return Color.red.opacity(0.35)
        }
    }
}
