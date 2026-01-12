//
//  Models.swift
//  BYB_mit02
//
//  Created by Vituruch Sinthusate on 7/1/2569 BE.
//

import Foundation

enum ScanType: String, CaseIterable {
    case url = "Link"
    case phone = "Phone"
    case bank = "Account"
    case qr = "QR Code"
    case text = "Text/File"
}

enum RiskLevel: String {
    case low, medium, high
}

struct ScanResult: Identifiable {
    let id = UUID()
    let type: ScanType
    let input: String
    let level: RiskLevel
    let reasons: [String]
    let timestamp: Date = Date()
}
