//
//  RiskService.swift
//  BYB_mit02
//
//  Created by Vituruch Sinthusate on 7/1/2569 BE.
//


import Foundation

final class RiskService {
    private let repo: ScamRepository

    init(repo: ScamRepository) {
        self.repo = repo
    }

    private var googleKey: String {
        return Bundle.main.object(forInfoDictionaryKey: "GoogleSafeBrowsingKey") as? String ?? ""
    }

    private var vtKey: String {
        return Bundle.main.object(forInfoDictionaryKey: "VirusTotalKey") as? String ?? ""
    }

    func scan(type: ScanType, input: String) async -> ScanResult {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1. เช็ค DB ในเครื่องก่อนเสมอ
        let matches = await repo.findMatches(type: type, input: trimmed)
        if !matches.isEmpty {
            return ScanResult(type: type, input: trimmed, level: .high, reasons: matches.map { "ฐานข้อมูลมิจฉาชีพ: \($0.label)" })
        }

        if type == .url {
            return await performAdvancedLinkScan(url: trimmed)
        }
        
        return ScanResult(type: type, input: trimmed, level: .low, reasons: ["ไม่พบข้อมูลมิจฉาชีพ"])
    }

    private func performAdvancedLinkScan(url: String) async -> ScanResult {
        // 1. ดัก Human Error (โค้ดเดิม)
        if !url.contains(".") || url.contains(" ") {
            return ScanResult(type: .url, input: url, level: .low, reasons: ["ไม่สามารถตรวจสอบได้เนื่องจากไม่พบที่อยู่ของเว็บไซต์"])
        }

        let expandedURL = await expandShortURL(url)
        var reasons: [String] = []
        var isHighRisk = false // ✅ ตัวแปรช่วยตัดสินใจ

        if expandedURL.lowercased() != url.lowercased() {
            reasons.append("🔍 ตรวจพบลิงก์แฝง: \(expandedURL)")
        }

        // ✅ 2. เช็คการแอบอ้างแบรนด์ และปรับระดับเป็น High ทันที
        if let brandWarning = checkBrandImpersonation(url: expandedURL) {
            reasons.append("⚠️ \(brandWarning)")
            isHighRisk = true // 🚩 มาร์คไว้ว่าเสี่ยงสูง
        }

        // 3. เช็ค Mock Data (โค้ดเดิม)
        let scamMocks = ["scam-test1.com", "fake-bank-login.net", "lottery-prize-winner.online"]
        if scamMocks.contains(where: { expandedURL.lowercased().contains($0) }) {
            reasons.append("[MOCK] ตรวจพบประวัติมิจฉาชีพ")
            return ScanResult(type: .url, input: expandedURL, level: .high, reasons: reasons)
        }

        // 4. เรียก Real API
        let google = await checkGoogleSafeBrowsing(url: expandedURL)
        let vt = await checkVirusTotal(url: expandedURL)

        // ✅ 5. สรุปผลใหม่: ถ้า Google เจอ หรือ เป็นเว็บปลอมแบรนด์ ให้ขึ้นสีแดง (High)
        if google.isScam || isHighRisk || vt.maliciousCount >= 3 {
            if google.isScam { reasons.append(contentsOf: google.reasons) }
            if vt.maliciousCount >= 3 { reasons.append("VirusTotal: ตรวจพบความเสี่ยงสูง") }
            
            return ScanResult(type: .url, input: expandedURL, level: .high, reasons: reasons)
        }
        
        // ถ้าพบใน VirusTotal นิดหน่อย ให้ขึ้นสีส้ม (Medium)
        if vt.maliciousCount > 0 {
            reasons.append("VirusTotal: พบความน่าสงสัยจาก \(vt.maliciousCount) แหล่ง")
            return ScanResult(type: .url, input: expandedURL, level: .medium, reasons: reasons)
        }

        if reasons.isEmpty {
            reasons.append("ปลอดภัย: ไม่พบประวัติความเสี่ยงจากฐานข้อมูลสากล")
        }
        
        return ScanResult(type: .url, input: expandedURL, level: .low, reasons: reasons)
    }

    // --- Helper Functions ---
    
    private func expandShortURL(_ urlString: String) async -> String {
        let shorteners = ["bit.ly", "tinyurl.com", "t.co", "rebrand.ly", "shorturl.at"]
        guard shorteners.contains(where: { urlString.contains($0) }),
              let url = URL(string: urlString.hasPrefix("http") ? urlString : "https://\(urlString)") else { return urlString }
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            return response.url?.absoluteString ?? urlString
        } catch { return urlString }
    }

    private func checkBrandImpersonation(url: String) -> String? {
        let brands = ["kbank", "scb", "shopee", "lazada", "krungthai"]
        let official = ["kasikornbank.com", "scb.co.th", "shopee.co.th", "lazada.co.th", "krungthai.com"]
        let lower = url.lowercased()
        for (i, b) in brands.enumerated() {
            if lower.contains(b) && !lower.contains(official[i]) {
                return "พบความพยายามแอบอ้างชื่อแบรนด์ (\(b.uppercased()))"
            }
        }
        return nil
    }

    // --- API Methods (Google & VT) ---
    private func checkGoogleSafeBrowsing(url: String) async -> (isScam: Bool, reasons: [String]) {
        guard !googleKey.isEmpty else { return (false, []) }
        let endpoint = "https://safebrowsing.googleapis.com/v4/threatMatches:find?key=\(googleKey)"
        guard let urlObj = URL(string: endpoint) else { return (false, []) }
        let body: [String: Any] = ["client": ["clientId": "BYB-App", "clientVersion": "1.0.0"], "threatInfo": ["threatTypes": ["MALWARE", "SOCIAL_ENGINEERING", "UNWANTED_SOFTWARE"], "platformTypes": ["ANY_PLATFORM"], "threatEntryTypes": ["URL"], "threatEntries": [["url": url]]]]
        var request = URLRequest(url: urlObj); request.httpMethod = "POST"; request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do { request.httpBody = try JSONSerialization.data(withJSONObject: body); let (data, _) = try await URLSession.shared.data(for: request); let decoded = try JSONDecoder().decode(GoogleSBResponse.self, from: data); if let matches = decoded.matches, !matches.isEmpty { return (true, ["Google: ตรวจพบว่าเป็นเว็บไซต์อันตราย"]) } } catch { return (false, []) }
        return (false, [])
    }

    private func checkVirusTotal(url: String) async -> (maliciousCount: Int, reasons: [String]) {
        guard !vtKey.isEmpty else { return (0, []) }
        let urlId = Data(url.utf8).base64EncodedString().replacingOccurrences(of: "=", with: "").replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_")
        let endpoint = "https://www.virustotal.com/api/v3/urls/\(urlId)"
        guard let urlObj = URL(string: endpoint) else { return (0, []) }
        var request = URLRequest(url: urlObj); request.addValue(vtKey, forHTTPHeaderField: "x-apikey"); request.addValue("application/json", forHTTPHeaderField: "Accept")
        do { let (data, _) = try await URLSession.shared.data(for: request); let decoded = try JSONDecoder().decode(VTResponse.self, from: data); return (decoded.data.attributes.last_analysis_stats?.maliciousCount ?? 0, []) } catch { return (0, []) }
    }
}

// Models
struct GoogleSBResponse: Codable { let matches: [ThreatMatch]? }
struct ThreatMatch: Codable { let threatType: String }
struct VTResponse: Codable { let data: VTData }
struct VTData: Codable { let attributes: VTAttributes }
struct VTAttributes: Codable { let last_analysis_stats: VTStats? }
struct VTStats: Codable { let malicious: Int?; var maliciousCount: Int { malicious ?? 0 } }
