import SwiftUI

struct ThaiResultView: View {
    let result: ScanResult

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(titleLine)
                    .font(.title2).bold()
                    .foregroundStyle(color)

                if let subject = subjectLine {
                    Text(subject)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if !result.reasons.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(reasonHeader)
                            .font(.headline)

                        ForEach(result.reasons, id: \.self) { reason in
                            Text("• \(reason)")
                                .font(.body)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
            }
            .padding(16)
        }
        .navigationTitle("Result")
    }

    private var isSafe: Bool { result.level == .low }

    private var color: Color {
        switch result.level {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }

    private var titleLine: String {
        switch result.type {
        case .url: return isSafe ? "ปลอดภัย" : "ไม่ปลอดภัย"
        case .bank: return isSafe ? "ข้อมูลบัญชี: ปลอดภัย" : "ข้อมูลบัญชี: ไม่ปลอดภัย"
        case .phone: return isSafe ? "เบอร์นี้: ปลอดภัย" : "เบอร์นี้: ไม่ปลอดภัย"
        case .qr: return isSafe ? "รูปภาพนี้: ปลอดภัย" : "รูปภาพนี้: ไม่ปลอดภัย"
        case .text: return isSafe ? "ข้อความนี้: ปลอดภัย" : "ข้อความนี้: ไม่ปลอดภัย"
        }
    }

    private var subjectLine: String? {
        switch result.type {
        case .url: return "ลิงก์: \(result.input)"
        case .bank: return "ชื่อ/บัญชี: \(result.input)"
        case .phone: return "เบอร์: \(result.input)"
        case .qr: return "ผลจากการสแกนรูปภาพ"
        case .text: return "ข้อความ/ไฟล์: \(result.input)"
        }
    }

    private var reasonHeader: String {
        isSafe ? "รายละเอียด" : "ไม่ปลอดภัย เนื่องจาก:"
    }
}
