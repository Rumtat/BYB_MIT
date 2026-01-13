//
//  MockScamRepository.swift
//  BYB_mit02
//
//  Created by Vituruch Sinthusate on 7/1/2569 BE.
//
import Foundation

// ✅ Protocol สำหรับเป็นโครงสร้างให้ RiskService เรียกใช้
protocol ScamRepository {
    func findMatches(type: ScanType, input: String) async -> [ScamEntry]
}

final class MockScamRepository: ScamRepository {
    private let data: [ScamEntry] = mockScamEntries

    func findMatches(type: ScanType, input: String) async -> [ScamEntry] {
        let q = input.trimmingCharacters(in: .whitespacesAndNewlines)

        switch type {
        case .phone:
            let digits = q.filter(\.isNumber)
            return data.filter { $0.kind == .phone && $0.value == digits }

        case .bank:
            let norm = q.replacingOccurrences(of: " ", with: "")
            return data.filter { $0.kind == .bankAccount && $0.value.replacingOccurrences(of: " ", with: "") == norm }

        case .url:
            return data.filter { $0.kind == .url && q.lowercased().contains($0.value.lowercased()) }

        case .text, .qr, .report:
            return data.filter { entry in q.lowercased().contains(entry.value.lowercased()) }
        }
    }
}
