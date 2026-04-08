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
    let matchedPatternName: String
    @ObservedObject var settings: AppSettings
    let onClose: () -> Void
    var onWidthChange: ((CGFloat) -> Void)? = nil
    var onDownloadRequested: ((NSImage, String, @escaping (Bool) -> Void) -> Void)? = nil

    @State private var dragStartWidth: CGFloat?
    @State private var isResizing = false
    @State private var lastSuccessAction: SuccessAction? = nil

    private enum SuccessAction: Equatable {
        case copy
        case download
    }

    var body: some View {
        VStack(spacing: 12) {
            if let image = BarcodeGenerator.generate(
                from: value,
                format: settings.format,
                width: settings.width,
                height: settings.height
            ) {
                infoBar(image: image)
            } else {
                infoBar(image: nil)
            }

            if let image = BarcodeGenerator.generate(
                from: value,
                format: settings.format,
                width: settings.width,
                height: settings.height
            ) {
                imageView(image: image)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func infoBar(image: NSImage?) -> some View {
        HStack(spacing: 10) {
            WindowDragRegion()
                .overlay(
                    HStack(spacing: 10) {
                        Text(settings.format.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.quaternary.opacity(0.8), in: Capsule())

                        Text(matchedPatternName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.quaternary.opacity(0.8), in: Capsule())

                        Text(value)
                            .font(.system(.subheadline, design: .monospaced))
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .allowsHitTesting(false)
                    }
                    .padding(.horizontal, 4)
                )
                .frame(maxWidth: .infinity)

            if let image = image {
                actionButton(
                    label: String(localized: "Copy"),
                    icon: "doc.on.doc",
                    successIcon: "checkmark.circle.fill",
                    isSuccess: lastSuccessAction == .copy
                ) {
                    copyToClipboard(image: image)
                    showSuccess(.copy)
                }

                actionButton(
                    label: String(localized: "Download"),
                    icon: "square.and.arrow.down",
                    successIcon: "checkmark.circle.fill",
                    isSuccess: lastSuccessAction == .download
                ) {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
                    let dateString = formatter.string(from: Date())
                    let patternSlug = Self.filenameSlug(from: matchedPatternName)
                    let suggestedName = "\(patternSlug)_\(dateString).png"
                    onDownloadRequested?(image, suggestedName) { success in
                        if success {
                            showSuccess(.download)
                        }
                    }
                }
            }

            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
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

    @ViewBuilder
    private func actionButton(
        label: String,
        icon: String,
        successIcon: String,
        isSuccess: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: isSuccess ? successIcon : icon)
                    .font(.body.weight(.medium))
                    .foregroundStyle(isSuccess ? .green : .primary)
                    .scaleEffect(isSuccess ? 1.1 : 1)
                    .animation(.easeInOut(duration: 0.2), value: isSuccess)
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    /// Slug sûr pour un nom de fichier (a-z, 0-9, tirets ; accents supprimés).
    private static func filenameSlug(from patternName: String) -> String {
        let folded = patternName.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        let parts = folded.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
        let slug = parts.joined(separator: "-")
        return slug.isEmpty ? "pattern" : slug
    }

    private func showSuccess(_ action: SuccessAction) {
        lastSuccessAction = action
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.2)) {
                lastSuccessAction = nil
            }
        }
    }

    private func copyToClipboard(image: NSImage) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([image])
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
    BarcodePanelView(
        value: "1234567890128",
        matchedPatternName: String(localized: "Global"),
        settings: AppSettings.shared,
        onClose: {}
    )
    .frame(width: 320, height: 120)
}
