//
//  AppDelegate.swift
//  ScanBarMenu
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var clipboardMonitor: ClipboardMonitor?
    var barcodePanelController: BarcodePanelController?
    private var welcomeWindow: NSWindow?

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

        if WelcomeView.shouldShowOnLaunch {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.showWelcomeWindow()
            }
        }
    }

    func showWelcomeWindow() {
        if let existing = welcomeWindow, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let hostingView = NSHostingView(
            rootView: WelcomeView(
                onDismiss: { [weak self] in
                    self?.closeWelcomeWindow()
                }
            )
        )

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 760),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: true
        )
        window.title = "Bienvenue – ScanBar Menu"
        window.contentView = hostingView
        window.center()
        window.isReleasedWhenClosed = false
        window.titlebarAppearsTransparent = false

        self.welcomeWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func closeWelcomeWindow() {
        welcomeWindow?.orderOut(nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        clipboardMonitor?.stop()
    }
}
