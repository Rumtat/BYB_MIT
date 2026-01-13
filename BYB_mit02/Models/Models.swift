//
//  Models.swift
//  BYB_mit02
//
//  Created by Vituruch Sinthusate on 7/1/2569 BE.
//

import Foundation

enum ScanType: String, CaseIterable, Codable {
    case url = "Link"
    case phone = "Phone"
    case bank = "Account"
    case qr = "QR Code"
    case text = "Text/File"
    case report = "Report" // ✅ เพิ่มเคสสำหรับหน้าแจ้งรายงาน
}
enum BankSearchMode: String, CaseIterable, Codable {
    case byAccount = "By Account"
    case byName = "By Name"
}

enum RiskLevel: String, Codable {
    case low, medium, high
    
    var isSafe: Bool {
        return self == .low
    }
    
    var displayTitle: String {
        switch self {
        case .low:
            return "ปลอดภัย"
        case .medium:
            return "มีความเสี่ยง"
        case .high:
            return "ไม่ปลอดภัย"
        }
    }
}

struct ScanResult: Identifiable, Codable, Hashable {
    let id: UUID
    let type: ScanType
    let input: String
    let level: RiskLevel
    let reasons: [String]
    let timestamp: Date

    init(type: ScanType, input: String, level: RiskLevel, reasons: [String]) {
        self.id = UUID()
        self.type = type
        self.input = input
        self.level = level
        self.reasons = reasons
        self.timestamp = Date()
    }
    
    var isSafe: Bool {
        return level == .low
    }
    
    var displayTitle: String {
        switch level {
        case .low:
            return "ปลอดภัย"
        case .medium:
            return "มีความเสี่ยง"
        case .high:
            return "ไม่ปลอดภัย"
        }
    }
}

