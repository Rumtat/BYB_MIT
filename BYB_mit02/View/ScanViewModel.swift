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
        
        // 1. ตรวจสอบจากฐานข้อมูลมิจฉาชีพก่อน
        let resultFromService = await performScan(type: .phone, input: metadata.cleanedNumber)
        
        if let r = resultFromService {
            var reasons = r.reasons
            var level = r.level // ค่าเริ่มต้นจาก Service (มักจะเป็น .low ถ้าไม่เจอใน DB)
            
            // --- ส่วนที่ต้องแก้ไขเพื่อให้เลิกแสดง "ปลอดภัย" ---
            
            // 2. ถ้าเป็นเบอร์ต่างประเทศ ให้บังคับเป็นระดับ Medium (มีความเสี่ยง) ทันที
            if metadata.origin.contains("ต่างประเทศ") {
                level = .medium
                reasons.insert("⚠️ ตรวจพบสายโทรเข้าจากต่างประเทศ มีความเสี่ยงสูงที่จะเป็นแก๊ง Call Center", at: 0)
            }
            
            // 3. ถ้าพบรูปแบบเลขผิดปกติ (Anomaly) ให้บังคับเป็นระดับ High (ไม่ปลอดภัย)
            if metadata.isHighRiskPattern {
                level = .high
                reasons.insert("🚩 รูปแบบหมายเลขผิดปกติ: ตรวจพบตัวเลขซ้ำกันมากเกินไป", at: 0)
            }
            
            // 4. ถ้าเป็นเบอร์ทางการที่ได้รับการยืนยัน (Verified) ให้คงระดับ .low ไว้
            if metadata.isVerifiedService {
                level = .low
                reasons = ["✅ ยืนยันแล้ว: หมายเลขติดต่ออย่างเป็นทางการ"]
            }
            
            // เพิ่มข้อมูลเชิงลึกเข้าไปในรายการเหตุผล
            reasons.append("แหล่งที่มา: \(metadata.origin)")
            reasons.append("เครือข่าย: \(metadata.carrier)")
            reasons.append("ประเภท: \(metadata.typeDescription)")

            // 5. สร้างผลลัพธ์สุดท้ายด้วย Level ที่ถูกวิเคราะห์ใหม่
            let finalResult = ScanResult(type: .phone, input: metadata.cleanedNumber, level: level, reasons: reasons)
            
            self.result = finalResult
            self.history.add(finalResult)
            return finalResult
        }
        
        return nil
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
