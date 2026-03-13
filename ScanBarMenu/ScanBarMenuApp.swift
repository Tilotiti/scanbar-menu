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

        Window("Configuration", id: "settings") {
            SettingsView(settings: AppSettings.shared)
                .frame(minWidth: 400, minHeight: 380)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 400, height: 380)
        .defaultPosition(.center)

        Window(String(localized: "À propos"), id: "about") {
            AboutView()
                .frame(minWidth: 360, minHeight: 400)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 360, height: 400)
        .defaultPosition(.center)
    }
}
