//
//  AppDelegate.swift
//  ScanBarMenu
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var clipboardMonitor: ClipboardMonitor?
    var barcodePanelController: BarcodePanelController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Masquer l'app du Dock (menu bar only)
        NSApp.setActivationPolicy(.accessory)

        let panelController = BarcodePanelController()
        self.barcodePanelController = panelController

        let monitor = ClipboardMonitor { [weak panelController] text, pattern in
            panelController?.showBarcode(text, matchedPattern: pattern)
        }
        self.clipboardMonitor = monitor
        monitor.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        clipboardMonitor?.stop()
    }

    /// Présente NSOpenPanel pour que l'utilisateur choisisse un dossier d'enregistrement.
    /// Conforme aux guidelines Apple : l'utilisateur choisit via une boîte de dialogue standard.
    func presentSaveFolderPicker(completion: @escaping (URL?) -> Void) {
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            let configTitle = String(localized: "Configuration")
            let window = HostingWindowStore.shared.settingsWindow
                ?? NSApp.windows.first { $0.title == configTitle }
                ?? NSApp.keyWindow

            let openPanel = NSOpenPanel()
            openPanel.canChooseFiles = false
            openPanel.canChooseDirectories = true
            openPanel.canCreateDirectories = true
            openPanel.prompt = String(localized: "Select")
            openPanel.message = String(localized: "Where to save generated images.")
            openPanel.title = String(localized: "Save folder")

            if let window {
                openPanel.beginSheetModal(for: window) { response in
                    let url = response == .OK ? openPanel.url : nil
                    DispatchQueue.main.async { completion(url) }
                }
            } else {
                let response = openPanel.runModal()
                let url = response == .OK ? openPanel.url : nil
                completion(url)
            }
        }
    }
}
