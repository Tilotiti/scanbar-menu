//
//  BarcodePanelView.swift
//  ScanBarMenu
//

import AppKit
import SwiftUI

private let displayWidthRange: ClosedRange<CGFloat> = 200 ... 1200

/// Zone dédiée pour déplacer la fenêtre (évite le conflit avec le redimensionnement).
struct WindowDragRegion: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = WindowDragHostView()
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

private final class WindowDragHostView: NSView {
    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }
}

struct BarcodePanelView: View {
    let value: String
    @ObservedObject var settings: AppSettings
    let onClose: () -> Void
    var onWidthChange: ((CGFloat) -> Void)? = nil

    @State private var dragStartWidth: CGFloat?
    @State private var isResizing = false

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                WindowDragRegion()
                    .overlay(
                        Text(value)
                            .font(.system(.body, design: .monospaced))
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .allowsHitTesting(false)
                    )
                    .frame(maxWidth: .infinity)

                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            if let image = BarcodeGenerator.generate(
                from: value,
                format: settings.format,
                width: settings.width,
                height: settings.height
            ) {
                imageView(image: image)
            }

            Text(settings.format.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func imageView(image: NSImage) -> some View {
        let currentWidth = settings.width
        let currentHeight = settings.height
        HStack(spacing: 0) {
            Image(nsImage: image)
                .interpolation(.none)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: currentWidth, height: currentHeight)
                .padding(.horizontal, 8)

            resizeHandle(currentWidth: currentWidth)
        }
    }

    private func resizeHandle(currentWidth: CGFloat) -> some View {
        Rectangle()
            .fill(isResizing ? Color.accentColor.opacity(0.3) : Color.clear)
            .frame(width: 12)
            .contentShape(Rectangle())
            .overlay(
                Image(systemName: "arrow.left.and.right")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            )
            .onHover { inside in
                if inside && !isResizing {
                    NSCursor.resizeLeftRight.push()
                } else if !isResizing {
                    NSCursor.pop()
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if dragStartWidth == nil {
                            dragStartWidth = settings.width
                            isResizing = true
                        }
                        let delta = value.translation.width
                        if let start = dragStartWidth {
                            let newWidth = min(max(start + delta, displayWidthRange.lowerBound), displayWidthRange.upperBound)
                            settings.width = newWidth
                            onWidthChange?(newWidth)
                        }
                    }
                    .onEnded { _ in
                        dragStartWidth = nil
                        isResizing = false
                        NSCursor.pop()
                    }
            )
    }
}

#Preview {
    BarcodePanelView(value: "1234567890128", settings: AppSettings.shared, onClose: {})
        .frame(width: 320, height: 120)
}
