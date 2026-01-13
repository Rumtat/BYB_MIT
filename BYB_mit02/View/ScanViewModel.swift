//
//  ScanViewModel.swift
//  BYB_mit02
//
//  Created by Vituruch Sinthusate on 12/1/2569 BE.
//

import SwiftUI
import Combine

@MainActor
final class ScanViewModel: ObservableObject {
    @Published var selectedType: ScanType = .url
    @Published var inputText: String = ""
    @Published var phoneDigits: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var result: ScanResult?
    @Published var isLoading = false
    @Published var errorMessage: String? // สำหรับแจ้งเตือนความผิดพลาด

    let history: HistoryStore
    private let service: RiskService
    private let phoneValidator = PhoneValidator() // เรียกใช้ตัวเช็คเบอร์

    init(history: HistoryStore) {
        self.history = history
        self.service = RiskService(repo: MockScamRepository())
    }

    convenience init() {
        self.init(history: HistoryStore())
    }

    // ✅ แยกฟังก์ชันสำหรับ SCAN PHONE
    // ใน ScanViewModel.swift
    // เพิ่มใน ScanViewModel.swift ภายในฟังก์ชัน runPhoneScan
    func runPhoneScan() async -> ScanResult? {
        guard let metadata = phoneValidator.validate(phoneDigits) else {
            self.errorMessage = "กรุณากรอกหมายเลขที่ถูกต้อง"
            return nil
        }
        
        self.errorMessage = nil
        
        // 1. เรียก Service และรับค่าเป็น Optional ScanResult?
        let resultFromService = await performScan(type: .phone, input: metadata.cleanedNumber)
        
        // ✅ แก้ปัญหา Error: ใช้ if let เพื่อเช็คว่ามีค่าส่งกลับมาจริงๆ (Unwrap)
        if let r = resultFromService {
            var reasons = r.reasons
            var level = r.level
            
            // 2. เสริม Logic ข้อมูลเชิงลึกจาก Metadata
            reasons.append("แหล่งที่มา: \(metadata.origin)")
            reasons.append("เครือข่าย: \(metadata.carrier)")
            reasons.append("ประเภท: \(metadata.typeDescription)")

            // 3. Logic ประเมินความเสี่ยงเพิ่มเติม
            if metadata.isHighRiskPattern {
                level = .high
                reasons.insert("ตรวจพบรูปแบบเบอร์ผิดปกติ (Anomaly): เลขซ้ำเกินความจำเป็น", at: 0)
            } else if metadata.origin == "ต่างประเทศ" && level == .low {
                level = .medium
                reasons.insert("ระวัง: เป็นสายโทรเข้าจากต่างประเทศ มักใช้ในกลโกง Call Center", at: 0)
            } else if metadata.isVerifiedService {
                level = .low
                reasons = ["ยืนยันแล้ว: เป็นหมายเลขติดต่อทางการของหน่วยงาน (\(metadata.typeDescription))"]
            }

            // 4. สร้าง Result ใหม่ที่รวม Logic ทั้งหมดแล้ว
            let finalResult = ScanResult(type: .phone, input: metadata.cleanedNumber, level: level, reasons: reasons)
            
            // อัปเดต State และ History
            self.result = finalResult
            self.history.add(finalResult)
            return finalResult
        }
        
        return nil // กรณี Service ส่งกลับมาเป็น nil
    }

    // ✅ แยกฟังก์ชันสำหรับ SCAN LINK
    func runLinkScan() async -> ScanResult? {
        let input = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !input.isEmpty else { return nil }
        
        // เช็คเบื้องต้นว่ามีจุดไหม (รูปแบบ URL)
        if !input.contains(".") {
            self.errorMessage = "รูปแบบลิงก์ไม่ถูกต้อง"
            return nil
        }
        
        self.errorMessage = nil
        return await performScan(type: .url, input: input)
    }

    // ฟังก์ชันกลางสำหรับส่งข้อมูลเข้า Service
    private func performScan(type: ScanType, input: String) async -> ScanResult? {
        isLoading = true
        defer { isLoading = false }

        let r = await service.scan(type: type, input: input)
        self.result = r
        self.history.add(r)
        return r
    }
    
    // รักษาฟังก์ชันเดิมไว้เพื่อรองรับ Type อื่นๆ (Bank, Text, QR)
    func runScan() async -> ScanResult? {
        let input = normalizedInputForScan().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { return nil }
        return await performScan(type: selectedType, input: input)
    }

    func normalizedInputForScan() -> String {
        switch selectedType {
        case .phone: return phoneDigits
        default: return inputText
        }
    }
    
    func clearAllInputs() {
        inputText = ""; phoneDigits = ""; firstName = ""; lastName = ""; errorMessage = nil
    }
}
