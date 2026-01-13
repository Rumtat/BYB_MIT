//
//  BYB_mit02App.swift
//  BYB_mit02
//
//  Created by Vituruch Sinthusate on 7/1/2569 BE.
//

import SwiftUI

@main
struct BYB_mit02App: App {
    var body: some Scene {
        WindowGroup {
            // ✅ ใส่ NavigationStack ครอบ ContentView ไว้ที่นี่ครับ
            NavigationStack {
                MainView()
            }
        }
    }
}
