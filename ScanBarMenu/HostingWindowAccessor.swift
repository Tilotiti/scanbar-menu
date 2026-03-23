//
//  HostingWindowAccessor.swift
//  ScanBarMenu
//

import AppKit
import SwiftUI

/// Permet d'obtenir la NSWindow qui héberge une vue SwiftUI.
struct HostingWindowAccessor: NSViewRepresentable {
    var onWindow: (NSWindow?) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        DispatchQueue.main.async {
            onWindow(view.window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            onWindow(nsView.window)
        }
    }
}

/// Stocke la fenêtre de configuration pour la réutiliser (ex: NSOpenPanel en sheet).
final class HostingWindowStore: ObservableObject {
    static let shared = HostingWindowStore()
    weak var settingsWindow: NSWindow?
}
