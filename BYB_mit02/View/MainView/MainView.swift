//
//  MainView.swift
//  BYB_mit02
//
//  Created by Vituruch Sinthusate on 7/1/2569 BE.
//

import SwiftUI
import PhotosUI

struct MainView: View {
    @StateObject private var vm = ScanViewModel()
    @State private var goResult: ScanResult?
    @State private var showLoading = false
    @State private var showSettings = false
    
    @State private var bankMode: BankSearchMode = .byAccount
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var historyClearedAt: Date? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 2. Header
                HeaderBar(onSettings: { showSettings = true })
                    .background(Color.blue.ignoresSafeArea(edges: .top))

                // 3. Scroll Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        if vm.selectedType == .report {
                            ReportScamView()
                        } else {
                            mainScanContent
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 150)
                }
            }

            // 4. Bottom Tab Bar
            BottomActionBar(
                selected: vm.selectedType,
                onSelect: { newType in
                    vm.selectedType = newType
                    vm.errorMessage = nil // ล้าง Error เวลาเปลี่ยนโหมด
                },
                onReport: { vm.selectedType = .report }
            )
            .background(Color.blue.ignoresSafeArea(edges: .bottom))
        }
        .navigationBarHidden(true)
        // ✅ ระบบแยกหน้า Result ตามประเภทข้อมูล
        .navigationDestination(item: $goResult) { result in
            if result.type == .phone {
                PhoneResultView(result: result)
            } else {
                ThaiResultView(result: result)
            }
        }
        .fullScreenCover(isPresented: $showLoading) { InlineLoadingView() }
        .sheet(isPresented: $showSettings) { SettingsView() }
    }

    private var mainScanContent: some View {
        VStack(spacing: 20) {
            TitleBlock(selectedType: vm.selectedType)

            InputCard(
                selectedType: vm.selectedType,
                inputText: $vm.inputText,
                phoneDigits: $vm.phoneDigits,
                firstName: $vm.firstName,
                lastName: $vm.lastName,
                bankMode: $bankMode,
                selectedPhotoItem: $selectedPhotoItem,
                onPickPhotoChanged: { vm.inputText = "IMAGE_SELECTED" },
                onPaste: pasteFromClipboard,
                onImportFile: { }
            )

            // ✅ แสดง Error Message สีแดง (เช่น "เบอร์ไม่ครบ", "เลขซ้ำผิดปกติ")
            if let error = vm.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, -10)
            }

            scanButton

            RecentSection(
                items: visibleHistoryItems,
                onClear: { historyClearedAt = Date() },
                onTap: { r in goResult = r }
            )
        }
        .padding(.horizontal, 16)
    }

    private var scanButton: some View {
        Button {
            Task {
                showLoading = true
                let res: ScanResult?
                
                // ✅ แยกการทำงานตาม Logic ที่คุณต้องการ
                switch vm.selectedType {
                case .phone:
                    res = await vm.runPhoneScan()
                case .url:
                    res = await vm.runLinkScan()
                default:
                    res = await vm.runScan()
                }
                
                showLoading = false
                
                if let r = res {
                    goResult = r
                    clearInputs()
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass").font(.system(size: 18, weight: .bold))
                Text(scanButtonTitle(for: vm.selectedType)).font(.headline)
            }
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(vm.normalizedInputForScan().isEmpty ? Color.gray.opacity(0.3) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal, 16)
        .disabled(vm.isLoading || vm.normalizedInputForScan().isEmpty)
    }

    // MARK: - Helpers
    private var visibleHistoryItems: [ScanResult] {
        guard let t = historyClearedAt else { return vm.history.items }
        return vm.history.items.filter { $0.timestamp > t }
    }

    private func clearInputs() {
        vm.clearAllInputs()
        selectedPhotoItem = nil
    }

    private func scanButtonTitle(for type: ScanType) -> String {
        switch type {
        case .url: return "SCAN LINK"
        case .phone: return "SCAN PHONE"
        case .bank: return "SCAN ACCOUNT"
        case .qr: return "SCAN IMAGE"
        case .text: return "SCAN TEXT"
        default: return ""
        }
    }

    private func pasteFromClipboard() {
        #if canImport(UIKit)
        if let s = UIPasteboard.general.string {
            vm.errorMessage = nil
            switch vm.selectedType {
            case .phone: 
                // ยอมให้มีเครื่องหมาย + จากการ Paste
                let allowed = "0123456789+"
                vm.phoneDigits = String(s.filter { allowed.contains($0) }.prefix(15))
            case .bank: 
                vm.inputText = String(s.filter { $0.isNumber }.prefix(15))
            default: 
                vm.inputText = s
            }
        }
        #endif
    }
}
