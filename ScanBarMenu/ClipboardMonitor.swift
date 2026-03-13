//
//  ClipboardMonitor.swift
//  ScanBarMenu
//

import AppKit
import Combine

final class ClipboardMonitor {
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int
    private var timer: Timer?
    private let interval: TimeInterval = 0.5
    private let onClipboardChange: (String) -> Void
    private let barcodeDetector = BarcodeDetector()

    init(onClipboardChange: @escaping (String) -> Void) {
        self.onClipboardChange = onClipboardChange
        self.lastChangeCount = pasteboard.changeCount
    }

    func start() {
        lastChangeCount = pasteboard.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func checkClipboard() {
        let currentChangeCount = pasteboard.changeCount
        guard currentChangeCount != lastChangeCount else { return }
        lastChangeCount = currentChangeCount

        guard let string = pasteboard.string(forType: .string) else { return }
        guard !string.isEmpty else { return }

        if barcodeDetector.isPotentialBarcode(string) {
            onClipboardChange(string)
        }
    }
}
