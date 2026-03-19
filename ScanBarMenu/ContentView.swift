//
//  ContentView.swift
//  ScanBarMenu
//

import SwiftUI

struct ContentView: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(String(localized: "How it works…")) {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "welcome")
            }

            Button(String(localized: "Configuration…")) {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "settings")
            }

            Button(String(localized: "About")) {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "about")
            }

            Divider()

            Button(String(localized: "Quit")) {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(8)
        .frame(width: 200)
        .onAppear {
            if WelcomeView.shouldShowOnLaunch {
                openWindow(id: "welcome")
            }
        }
    }
}

#Preview {
    ContentView()
}
