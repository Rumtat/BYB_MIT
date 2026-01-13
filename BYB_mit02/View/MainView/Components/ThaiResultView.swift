//
//  ThaiResultView.swift
//  BYB_mit02
//
//  Created by Vituruch Sinthusate on 11/1/2569 BE.
//


import SwiftUI

struct ThaiResultView: View {
    let result: ScanResult

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                // ✅ หัวข้อสถานะ
                Text(titleLine)
                    .font(.title2).bold()
                    .foregroundStyle(color)

                Text("ที่อยู่: \(result.input)").font(.subheadline).foregroundStyle(.secondary)

                // ✅ 1. เพิ่มภาพพรีวิวหน้าเว็บ (Preview)
                if !isInvalidFormat {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ภาพตัวอย่างหน้าเว็บ").font(.headline)
                        
                        let previewURL = "https://image.thum.io/get/width/600/crop/800/\(result.input.hasPrefix("http") ? result.input : "https://"+result.input)"
                        
                        AsyncImage(url: URL(string: previewURL)) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 180).clipped().cornerRadius(12)
                        } placeholder: {
                            Rectangle().fill(Color.gray.opacity(0.1))
                                .frame(height: 180).overlay(ProgressView()).cornerRadius(12)
                        }
                    }
                    .padding(.vertical, 8)
                }

                // ✅ 2. รายละเอียดความเสี่ยง
                if !result.reasons.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(reasonHeader).font(.headline)
                        ForEach(result.reasons, id: \.self) { reason in
                            HStack(alignment: .top) {
                                Text("•").bold()
                                Text(reason).font(.body)
                            }
                        }
                    }
                    .padding().frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))
                }
            }
            .padding(16)
        }
        .navigationTitle("Result")
    }

    private var isInvalidFormat: Bool { result.reasons.contains("ไม่สามารถตรวจสอบได้เนื่องจากไม่พบที่อยู่ของเว็บไซต์") }
    private var isSafe: Bool { result.level == .low }
    private var color: Color {
        if isInvalidFormat { return .gray }
        switch result.level {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
    private var titleLine: String {
        if isInvalidFormat { return "ไม่สามารถตรวจสอบได้" }
        return isSafe ? "ปลอดภัย" : "ไม่ปลอดภัย"
    }
    private var reasonHeader: String { isInvalidFormat ? "เหตุผล" : (isSafe ? "รายละเอียด" : "พบความเสี่ยงเนื่องจาก:") }
}
