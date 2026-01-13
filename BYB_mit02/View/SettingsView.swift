//
//  SettingsView.swift
//  BYB_mit02
//
//  Created by Vituruch Sinthusate on 8/1/2569 BE.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("General") {
                    NavigationLink("About", destination: Text("About"))
                    NavigationLink("Privacy", destination: Text("Privacy"))
                }
            }
            .navigationTitle("Settings")
        }
    }
}
