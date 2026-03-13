//
//  BarcodePanelView.swift
//  ScanBarMenu
//

import SwiftUI

struct BarcodePanelView: View {
    let value: String
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

            if let image = BarcodeGenerator.generateCode128(from: value) {
                Image(nsImage: image)
                    .interpolation(.none)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 90)
                    .padding(.horizontal, 8)
            }

            Text("Code-128")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    BarcodePanelView(value: "1234567890128", onClose: {})
        .frame(width: 320, height: 120)
}
