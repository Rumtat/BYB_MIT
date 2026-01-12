//
//  Result Screen.swift
//  BYB_mit02
//
//  Created by Vituruch Sinthusate on 7/1/2569 BE.
//

import SwiftUI

struct ResultView: View {
    let result: ScanResult

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Result").font(.title2)

            Text(result.level == .low ? "SAFE" : "NOT SAFE")
                .font(.largeTitle).bold()

            Text("Type: \(result.type.rawValue)")
            Text("Input: \(result.input)").lineLimit(6)

            Text("Reasons:")
                .font(.headline)
            ForEach(result.reasons, id: \.self) { Text("• \($0)") }

            Button("Report (MVP)") {
                // MVP: แค่ print/บันทึก local ก่อน
            }
            .frame(maxWidth: .infinity, minHeight: 44)

            Spacer()
        }
        .padding()
    }
}
