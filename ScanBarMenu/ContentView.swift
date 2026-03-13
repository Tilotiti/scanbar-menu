//
//  ContentView.swift
//  ScanBarMenu
//

import SwiftUI

struct ContentView: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button("Configuration…") {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "settings")
            }

            Button(String(localized: "À propos")) {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "about")
            }

            Divider()

            Button("Quitter") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(8)
        .frame(width: 180)
    }
}

#Preview {
    ContentView()
}
