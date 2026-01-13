//
//  ReportScamView.swift
//  BYB_mit02
//
//  Created by Vituruch Sinthusate on 8/1/2569 BE.
//

import SwiftUI

struct ReportScamView: View {
    // 1. State สำหรับเก็บข้อมูลฟอร์ม
    @State private var fullName = ""
    @State private var phoneNumber = ""
    @State private var bankAccount = ""
    @State private var email = ""
    @State private var scamType = "Call Center"
    @State private var dateOccurred = Date()
    @State private var amount = ""
    @State private var details = ""
    
    // สำหรับจัดการการส่งข้อมูล
    @State private var isSubmitting = false
    @State private var navigateToSuccess = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // ส่วนหัวข้อภายในหน้า
                VStack(alignment: .leading, spacing: 6) {
                    Text("REPORT SCAM")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(Color(red: 0.10, green: 0.16, blue: 0.35))
                    
                    Text("ข้อมูลของคุณมีความสำคัญในการหยุดยั้งมิจฉาชีพ")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // Form Card: รวบรวมช่องกรอกข้อมูล
                VStack(spacing: 20) {
                    Group {
                        RSInputField(label: "ชื่อ-นามสกุล ผู้แจ้ง", text: $fullName, placeholder: "ระบุชื่อของคุณ")
                        RSInputField(label: "เบอร์โทรศัพท์ที่ใช้ติดต่อ", text: $phoneNumber, placeholder: "08x-xxx-xxxx", keyboard: .phonePad)
                        RSInputField(label: "เลขบัญชีที่เกี่ยวข้อง", text: $bankAccount, placeholder: "ระบุเลขบัญชี", keyboard: .numberPad)
                        RSInputField(label: "Email", text: $email, placeholder: "example@mail.com", keyboard: .emailAddress)
                    }
                    
                    Divider().background(Color.blue.opacity(0.1))
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ประเภทการโกง")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(red: 0.10, green: 0.16, blue: 0.35))
                        
                        Picker("ประเภท", selection: $scamType) {
                            Text("Call Center").tag("Call Center")
                            Text("SMS หลอกลวง").tag("SMS หลอกลวง")
                            Text("แอปดูดเงิน").tag("แอปดูดเงิน")
                            Text("ซื้อของไม่ตรงปก").tag("ซื้อของไม่ตรงปก")
                            Text("อื่นๆ").tag("อื่นๆ")
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.blue.opacity(0.2), lineWidth: 1.5))
                    }
                    
                    DatePicker("วันที่เกิดเหตุ", selection: $dateOccurred, displayedComponents: .date)
                        .font(.system(size: 14, weight: .bold))
                    
                    RSInputField(label: "จำนวนเงินที่เสียหาย", text: $amount, placeholder: "0.00", keyboard: .decimalPad)
                    
                    RSInputField(label: "รายละเอียดเพิ่มเติม", text: $details, placeholder: "เล่าพฤติกรรมมิจฉาชีพ...", isLongText: true)
                    
                    // ปุ่มส่งรายงาน
                    Button {
                        submitReport()
                    } label: {
                        if isSubmitting {
                            ProgressView().tint(.white)
                        } else {
                            Text("ส่งรายงานสแกม")
                                .font(.system(size: 17, weight: .heavy))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(LinearGradient(colors: [Color(red: 0.12, green: 0.19, blue: 0.55), Color(red: 0.17, green: 0.30, blue: 0.78)], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(16)
                    .shadow(color: Color(red: 0.17, green: 0.30, blue: 0.78).opacity(0.3), radius: 10, x: 0, y: 5)
                    .disabled(isSubmitting)
                }
                .padding(25)
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.04), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .background(Color(red: 0.97, green: 0.98, blue: 0.99))
        // นำทางไปหน้า Success เมื่อส่งสำเร็จ
        .navigationDestination(isPresented: $navigateToSuccess) {
            ReportSuccessView(isPresented: $navigateToSuccess)
        }
    }
    
    private func submitReport() {
        isSubmitting = true
        // จำลองการส่งข้อมูลไป Server
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            navigateToSuccess = true
        }
    }
}

struct RSInputField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    var keyboard: UIKeyboardType = .default
    var isLongText: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.10, green: 0.16, blue: 0.35))
            
            TextField(placeholder, text: $text, axis: isLongText ? .vertical : .horizontal)
                .keyboardType(keyboard)
                .lineLimit(isLongText ? 5 : 1)
                .padding(15)
                .background(Color(red: 0.98, green: 0.98, blue: 0.99))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue.opacity(0.1), lineWidth: 1.5))
        }
    }
}
#Preview {
    ReportScamView()
}
