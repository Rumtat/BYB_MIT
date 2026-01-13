//
//  TitleBlock.swift
//  BYB_mit02
//
//  Created by Vituruch Sinthusate on 11/1/2569 BE.
//

import SwiftUI

struct TitleBlock: View {
    let selectedType: ScanType

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.title2).bold()

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 18)
        }
        .padding(.top, 8)
    }

    private var title: String {
        switch selectedType {
        case .url: return "LINK SCANNER"
        case .phone: return "PHONE SCANNER"
        case .bank: return "ACCOUNT SCANNER"
        case .qr: return "IMAGE SCANNER"
        case .text: return "TEXT SCANNER"
        case .report: return "REPORT SCAM"
                    }
    }

    private var subtitle: String {
        switch selectedType {
        case .url: return "ตรวจสอบลิงก์น่าสงสัยเพื่อประเมินความเสี่ยง"
        case .phone: return "ตรวจสอบเบอร์โทรศัพท์ที่น่าสงสัย"
        case .bank: return "ตรวจสอบบัญชีธนาคาร/พร้อมเพย์ที่น่าสงสัย"
        case .qr: return "สแกนรูปภาพเพื่อประเมินความเสี่ยง"
        case .text: return "วางข้อความหรือข้อมูลจากไฟล์เพื่อประเมินความเสี่ยง"
        case .report: return "แจ้งข้อมูลมิจฉาชีพเพื่อความปลอดภัยของสังคม"
            
        }
    }
}
