//
//  ViewModel.swift
//  BYB_mit02
//
//  Created by Vituruch Sinthusate on 7/1/2569 BE.
//

import Foundation

@MainActor
final class ScanViewModel: ObservableObject {
    @Published var selectedType: ScanType = .url
    @Published var inputText: String = ""
    @Published var result: ScanResult?
    @Published var isLoading = false

    private let service = RiskService()

    func runScan() async {
        isLoading = true
        defer { isLoading = false }
        result = await service.scan(type: selectedType, input: inputText)
    }
}
