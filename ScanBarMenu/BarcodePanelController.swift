//
//  BarcodePanelController.swift
//  ScanBarMenu
//

import AppKit
import SwiftUI

final class BarcodePanelController: NSObject {
    private var panel: NSPanel?
    private var hostingView: NSHostingView<BarcodePanelView>?
    private var currentValue: String = ""
    private var clickMonitor: Any?

    func showBarcode(_ value: String) {
        let settings = AppSettings.shared
        guard BarcodeGenerator.generate(
            from: value,
            format: settings.format,
            width: settings.width,
            height: settings.height
        ) != nil else { return }

        if let panel = panel, panel.isVisible {
            guard value != currentValue else { return }
            currentValue = value
            hostingView?.rootView = BarcodePanelView(
                value: value,
                settings: AppSettings.shared,
                onClose: { [weak self] in self?.hide() }
            )
            panel.orderFrontRegardless()
        } else {
            currentValue = value
            createAndShowPanel(value: value)
        }
    }

    func hide() {
        stopClickMonitor()
        panel?.orderOut(nil)
    }

    private func startClickMonitor() {
        stopClickMonitor()
        clickMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            guard let self = self, let panel = self.panel, panel.isVisible else { return event }
            let location = NSEvent.mouseLocation
            let panelFrame = panel.frame
            if !panelFrame.contains(location) {
                self.hide()
            }
            return event
        }
    }

    private func stopClickMonitor() {
        if let monitor = clickMonitor {
            NSEvent.removeMonitor(monitor)
            clickMonitor = nil
        }
    }

    private func createAndShowPanel(value: String) {
        let contentView = BarcodePanelView(
            value: value,
            settings: AppSettings.shared,
            onClose: { [weak self] in self?.hide() }
        )
        let hostingView = NSHostingView(rootView: contentView)
        self.hostingView = hostingView

        let settings = AppSettings.shared
        let panelWidth: CGFloat = max(360, settings.width + 80)
        let panelHeight: CGFloat = max(200, settings.height + 120)
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )

        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hidesOnDeactivate = false
        panel.contentView = hostingView

        self.panel = panel

        positionPanel(panel)
        startClickMonitor()
        panel.orderFrontRegardless()
    }

    private func positionPanel(_ panel: NSPanel) {
        guard let screen = NSScreen.main else { return }

        let menuBarHeight: CGFloat = 24
        let margin: CGFloat = 12
        let panelFrame = panel.frame
        let screenFrame = screen.visibleFrame

        let x = screenFrame.maxX - panelFrame.width - margin
        let y = screenFrame.maxY - panelFrame.height - menuBarHeight - margin

        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
