//
//  BarcodePanelView.swift
//  ScanBarMenu
//

import SwiftUI

struct BarcodePanelView: View {
    let value: String
    let settings: AppSettings
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(value)
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(maxWidth: .infinity, alignment: .leading)

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
                Image(nsImage: image)
                    .interpolation(.none)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: settings.width + 16, maxHeight: settings.height + 16)
                    .padding(.horizontal, 8)
            }

            Text(settings.format.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    BarcodePanelView(value: "1234567890128", settings: AppSettings.shared, onClose: {})
        .frame(width: 320, height: 120)
}
