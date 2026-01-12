//
//  ContentView.swift
//  BYB_mit02
//
//  Created by Vituruch Sinthusate on 7/1/2569 BE.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var vm = ScanViewModel()
    @State private var goResult: ScanResult?
    @State private var showLoading = false
    @State private var showSettings = false
    
    @State private var bankMode: BankSearchMode = .byAccount
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var historyClearedAt: Date? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ส่วนหัว
                HeaderBar(onSettings: { showSettings = true })

                ScrollView {
                    VStack(spacing: 18) {
                        TitleBlock(selectedType: vm.selectedType)

                        // การ์ดรับข้อมูล
                        InputCard(
                            selectedType: vm.selectedType,
                            inputText: $vm.inputText,
                            phoneDigits: $vm.phoneDigits,
                            firstName: $vm.firstName,
                            lastName: $vm.lastName,
                            bankMode: $bankMode,
                            selectedPhotoItem: $selectedPhotoItem,
                            onPickPhotoChanged: {
                                vm.inputText = (selectedPhotoItem == nil ? "" : "IMAGE_SELECTED")
                            },
                            onPaste: pasteFromClipboard,
                            onImportFile: { /* TODO */ }
                        )

                        // ปุ่มสแกน
                        ScanButton(title: scanButtonTitle(for: vm.selectedType),
                                   isDisabled: vm.isLoading || vm.normalizedInputForScan().isEmpty) {
                            performScan()
                        }

                        // ประวัติการสแกน
                        RecentSection(items: visibleHistoryItems) { r in goResult = r }

                        // ส่วนปุ่มจัดการประวัติและรายงาน
                        FooterActionButtons(
                            isClearDisabled: visibleHistoryItems.isEmpty,
                            onClear: { historyClearedAt = Date() }
                        )
                    }
                    .padding(.top, 14)
                }

                // แถบเมนูด้านล่าง
                BottomActionBar(selected: vm.selectedType) { vm.selectedType = $0 }
            }
            .navigationBarHidden(true)
            .navigationDestination(item: $goResult) { ThaiResultView(result: $0) }
            .fullScreenCover(isPresented: $showLoading) { InlineLoadingView() }
            .sheet(isPresented: $showSettings) { SettingsView() }
        }
    }

    // MARK: - Logic Functions
    private func performScan() {
        Task {
            showLoading = true
            try? await Task.sleep(nanoseconds: 700_000_000)
            if let r = await vm.runScan() {
                showLoading = false
                goResult = r
                clearInputs()
            } else {
                showLoading = false
            }
        }
    }

    private func clearInputs() {
        vm.inputText = ""; vm.phoneDigits = ""; vm.firstName = ""; vm.lastName = ""
        selectedPhotoItem = nil
    }

    private var visibleHistoryItems: [ScanResult] {
        guard let t = historyClearedAt else { return vm.history.items }
        return vm.history.items.filter { $0.timestamp > t }
    }

    private func scanButtonTitle(for type: ScanType) -> String {
        switch type {
        case .url: return "SCAN LINK"
        case .phone: return "SCAN PHONE"
        case .bank: return "SCAN ACCOUNT"
        case .qr: return "SCAN IMAGE"
        case .text: return "SCAN TEXT"
        }
    }

    private func pasteFromClipboard() {
        #if canImport(UIKit)
        if let s = UIPasteboard.general.string {
            switch vm.selectedType {
            case .phone: vm.phoneDigits = String(s.filter { $0.isNumber }.prefix(10))
            case .bank: vm.inputText = String(s.filter { $0.isNumber }.prefix(12))
            default: vm.inputText = s
            }
        }
        #endif
    }
}

#Preview {
    ContentView()
}
