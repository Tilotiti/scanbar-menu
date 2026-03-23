//
//  ScanBarMenuApp.swift
//  ScanBarMenu
//
//  Application macOS menu bar pour afficher les codes-barres copiés.
//

import SwiftUI

@main
struct ScanBarMenuApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            ContentView()
        } label: {
            Image(systemName: "barcode.viewfinder")
        }

        Window(String(localized: "Configuration"), id: "settings") {
            SettingsView(settings: AppSettings.shared)
                .frame(minWidth: 400, minHeight: 380)
                .overlay(
                    HostingWindowAccessor { window in
                        HostingWindowStore.shared.settingsWindow = window
                    }
                    .frame(width: 1, height: 1)
                    .allowsHitTesting(false)
                )
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 400, height: 380)
        .defaultPosition(.center)

        Window(String(localized: "About"), id: "about") {
            AboutView()
                .frame(minWidth: 360, minHeight: 400)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 360, height: 400)
        .defaultPosition(.center)

        Window("Bienvenue – ScanBar Menu", id: "welcome") {
            WelcomeView(onDismiss: nil)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 560, height: 760)
        .defaultPosition(.center)
    }
}
