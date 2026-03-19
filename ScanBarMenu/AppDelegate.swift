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

        let monitor = ClipboardMonitor { [weak panelController] text in
            panelController?.showBarcode(text)
        }
        self.clipboardMonitor = monitor
        monitor.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        clipboardMonitor?.stop()
    }
}
