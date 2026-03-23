//
//  ContentView.swift
//  ScanBarMenu
//

import SwiftUI

extension Notification.Name {
    static let openSettingsWindow = Notification.Name("openSettingsWindow")
}

struct ContentView: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(String(localized: "How it works…")) {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "welcome")
            }

            Button(String(localized: "Configuration…")) {
                openConfigurationWindow(openWindow: openWindow)
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
        .onReceive(NotificationCenter.default.publisher(for: .openSettingsWindow)) { _ in
            openConfigurationWindow(openWindow: openWindow)
        }
    }

    private func openConfigurationWindow(openWindow: OpenWindowAction) {
        NSApp.setActivationPolicy(.regular)
        NSRunningApplication.current.activate(options: [.activateIgnoringOtherApps, .activateAllWindows])
        openWindow(id: "settings")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            NSApp.activate(ignoringOtherApps: true)
            let configTitle = String(localized: "Configuration")
            if let win = NSApp.windows.first(where: { $0.title == configTitle }) {
                win.makeKeyAndOrderFront(nil)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            NSApp.activate(ignoringOtherApps: true)
            let configTitle = String(localized: "Configuration")
            NSApp.windows.first { $0.title == configTitle }?.makeKeyAndOrderFront(nil)
        }
    }
}

#Preview {
    ContentView()
}
