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
    }
}
