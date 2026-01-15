import FirebaseFirestore
import Foundation

class FirebaseRepository {
    private let db = Firestore.firestore()

    func checkBlacklist(input: String) async -> ScanResult? {
        do {
            // ดึงข้อมูลจากคอลเลกชันใหม่ที่คุณสร้าง
            let snapshot = try await db.collection("phone_blacklist").document(input).getDocument()
            
            if snapshot.exists, let data = snapshot.data() {
                // แปลงข้อมูลจาก Firebase เป็น ScanResult
                let typeStr = data["type"] as? String ?? "phone"
                let levelStr = data["level"] as? String ?? "low"
                let reasons = data["reasons"] as? [String] ?? []
                
                return ScanResult(
                    type: ScanType(rawValue: typeStr) ?? .phone,
                    input: input,
                    level: mapLevel(levelStr),
                    reasons: reasons
                )
            }
        } catch {
            print("❌ Firebase Error: \(error.localizedDescription)")
        }
        return nil // ถ้าไม่เจอข้อมูล หรือ Error ให้คืนค่า nil
    }

    private func mapLevel(_ level: String) -> RiskLevel {
        switch level {
        case "high": return .high
        case "medium": return .medium
        default: return .low
        }
    }
}