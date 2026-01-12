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
    @State private var showReport = false

    // local state (ยังไม่ผูกกับ VM เพื่อไม่ให้ error)
    @State private var bankMode: BankSearchMode = .byAccount
    @State private var selectedPhotoItem: PhotosPickerItem? = nil

    // Clear history แบบ “หายจาก UI” (เพราะ history.items แก้ตรง ๆ ไม่ได้)
    @State private var historyClearedAt: Date? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HeaderBar(onSettings: { showSettings = true })

                ScrollView {
                    VStack(spacing: 18) {
                        TitleBlock(selectedType: vm.selectedType)

                        InputCard(
                            selectedType: vm.selectedType,
                            inputText: $vm.inputText,
                            phoneDigits: $vm.phoneDigits,
                            firstName: $vm.firstName,
                            lastName: $vm.lastName,
                            bankMode: $bankMode,
                            selectedPhotoItem: $selectedPhotoItem,
                            onPickPhotoChanged: {
                                // placeholder ให้ปุ่ม scan ไม่ disabled ตอนเลือกรูป
                                vm.inputText = (selectedPhotoItem == nil ? "" : "IMAGE_SELECTED")
                            },
                            onPaste: pasteFromClipboard,
                            onImportFile: {
                                // TODO: document picker (text/file)
                            }
                        )

                        scanButton

                        RecentSection(items: visibleHistoryItems, onTap: { r in
                            goResult = r
                        })

                        actionButtons
                    }
                    .padding(.top, 14)
                }

                BottomActionBar(selected: vm.selectedType) { newType in
                    vm.selectedType = newType
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(item: $goResult) { r in
                ThaiResultView(result: r)
            }
            .fullScreenCover(isPresented: $showLoading) {
                InlineLoadingView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }

            // NOTE: อันเดิมคุณมี showReport แต่ไปใช้ NavigationLink ด้วย
            // ถ้าจะใช้ sheet ก็ทำได้ แต่ตอนนี้คงไว้แบบเดิม:
            // .sheet(isPresented: $showReport) { ReportScamView() }
        }
    }

    private var scanButton: some View {
        Button {
            Task {
                showLoading = true
                try? await Task.sleep(nanoseconds: 700_000_000)

                if let r = await vm.runScan() {
                    showLoading = false
                    goResult = r

                    // Scan แล้วเคลียร์ input ไม่ให้ค้างในช่อง
                    vm.inputText = ""
                    vm.phoneDigits = ""
                    vm.firstName = ""
                    vm.lastName = ""
                    selectedPhotoItem = nil
                } else {
                    showLoading = false
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.headline)
                Text(scanButtonTitle(for: vm.selectedType))
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, minHeight: 52)
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal, 16)
        .disabled(vm.isLoading || vm.normalizedInputForScan().trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    private var actionButtons: some View {
        HStack(spacing: 14) {
            Button {
                historyClearedAt = Date()
            } label: {
                Text("CLEAR HISTORY")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.bordered)
            .disabled(visibleHistoryItems.isEmpty)

            Button {
                showReport = true
            } label: {
                Text("REPORT SCAM")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.bordered)

            // คง NavigationLink เดิมไว้ (ถ้าอยากใช้ปุ่ม REPORT SCAM เดียวกัน แนะนำเปลี่ยนให้ไปลิงก์แทน)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 18)
        .overlay(alignment: .bottom) {
            // เอา NavigationLink เดิมของคุณมาไว้ในที่เหมาะสม (เลือกอย่างใดอย่างหนึ่ง)
            NavigationLink(destination: ReportScamView()) {
                EmptyView()
            }
            .opacity(0)
        }
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
            case .phone:
                let digits = s.filter { $0.isNumber }
                vm.phoneDigits = String(digits.prefix(10))

            case .bank:
                if bankMode == .byAccount {
                    let digits = s.filter { $0.isNumber }
                    vm.inputText = String(digits.prefix(12))
                } else {
                    vm.inputText = s
                }

            default:
                vm.inputText = s
            }
        }
        #endif
    }
}

#Preview {
    MainView()
}
