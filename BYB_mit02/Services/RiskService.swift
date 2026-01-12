//
//  RiskService.swift
//  BYB_mit02
//
//  Created by Vituruch Sinthusate on 7/1/2569 BE.
//

import Foundation

final class RiskService {
    func scan(type: ScanType, input: String) async -> ScanResult {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)

        var level: RiskLevel = .low
        var reasons: [String] = ["No strong risk signal (mock)."]

        // Mock rules (แทน External API ชั่วคราว)
        if trimmed.lowercased().contains("bit.ly") || trimmed.lowercased().contains("tinyurl") {
            level = .high
            reasons = ["Short-link detected (often used in phishing)."]
        } else if trimmed.lowercased().contains("http://") {
            level = .medium
            reasons = ["Non-HTTPS link detected."]
        } else if trimmed.count > 300 {
            level = .medium
            reasons = ["Input length unusually long (>300)."]
        }

        return ScanResult(type: type, input: trimmed, level: level, reasons: reasons)
    }
}
