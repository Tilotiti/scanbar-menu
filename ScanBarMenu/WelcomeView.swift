//
//  WelcomeView.swift
//  ScanBarMenu
//

import AppKit
import SwiftUI

struct WelcomeView: View {
    @Environment(\.dismiss) private var dismiss
    var onDismiss: (() -> Void)?

    private static let exampleCode = "1234567890128"

    var body: some View {
        VStack(spacing: 0) {
            header
            infographic
            footer
        }
        .padding(EdgeInsets(top: 56, leading: 24, bottom: 48, trailing: 24))
        .frame(minWidth: 512, minHeight: 712)
        .background(
            LinearGradient(
                colors: [
                    Color(nsColor: .windowBackgroundColor),
                    Color(nsColor: .windowBackgroundColor).opacity(0.97)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(String(localized: "How does it work?"))
                .font(.title)
                .fontWeight(.semibold)

            Text(String(localized: "Display your barcodes and QR codes on screen with one click."))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var infographic: some View {
        VStack(spacing: 0) {
            stepRow(
                number: 1,
                title: String(localized: "Copy the reference"),
                subtitle: String(localized: "On your Mac or from your iPhone (AirDrop, copy-paste)"),
                content: { step1Content }
            )

            stepConnector

            stepRow(
                number: 2,
                title: String(localized: "ScanBar displays the code"),
                subtitle: String(localized: "The barcode or QR code appears automatically on your screen"),
                content: { step2Content }
            )

            stepConnector

            stepRow(
                number: 3,
                title: String(localized: "Scan the screen"),
                subtitle: String(localized: "Use your scanner or camera to scan the screen"),
                content: { step3Content }
            )
        }
    }

    private var stepConnector: some View {
        Image(systemName: "arrow.down")
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.tertiary)
            .padding(.vertical, 6)
    }

    private func stepRow<Content: View>(
        number: Int,
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(alignment: .top, spacing: 20) {
            stepNumberBadge(number: number)

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                content()
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
    }

    private func stepNumberBadge(number: Int) -> some View {
        Text("\(number)")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .frame(width: 36, height: 36)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
    }

    @ViewBuilder
    private var step1Content: some View {
        HStack(spacing: 16) {
            step1Device(icon: "desktopcomputer", label: String(localized: "Mac"))
            Image(systemName: "plus")
                .font(.caption)
                .foregroundStyle(.tertiary)
            step1Device(icon: "iphone", label: String(localized: "iPhone"))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.quinary.opacity(0.6), in: RoundedRectangle(cornerRadius: 8))

        HStack(spacing: 8) {
            Image(systemName: "doc.on.clipboard.fill")
                .font(.subheadline)
                .foregroundStyle(Color.accentColor)
            Text(String(localized: "Ex. « \(Self.exampleCode) »"))
                .font(.system(.subheadline, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }

    private func step1Device(icon: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(.primary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 70)
    }

    @ViewBuilder
    private var step2Content: some View {
        if let image = BarcodeGenerator.generate(
            from: Self.exampleCode,
            format: .code128,
            width: 280,
            height: 75
        ) {
            HStack {
                Image(nsImage: image)
                    .interpolation(.none)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 60)
                    .padding(12)
                    .background(Color.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.quaternary, lineWidth: 1)
                    )

                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
        }
    }

    @ViewBuilder
    private var step3Content: some View {
        HStack(spacing: 12) {
            Image(systemName: "viewfinder")
                .font(.system(size: 32))
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "Scanner or camera"))
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(String(localized: "The on-screen code is scannable like a physical code"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quinary.opacity(0.6), in: RoundedRectangle(cornerRadius: 8))
    }

    private var footer: some View {
        VStack(spacing: 16) {
            Button {
                markAsSeen()
                if let onDismiss {
                    onDismiss()
                } else {
                    dismiss()
                }
            } label: {
                Text(String(localized: "Got it"))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)

            Text(String(localized: "This window remains accessible from the menu"))
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.top, 16)
    }

    private func markAsSeen() {
        UserDefaults.standard.set(true, forKey: WelcomeView.hasSeenWelcomeKey)
    }

    static let hasSeenWelcomeKey = "hasSeenWelcome"

    static var shouldShowOnLaunch: Bool {
        !UserDefaults.standard.bool(forKey: hasSeenWelcomeKey)
    }
}

#Preview {
    WelcomeView()
        .frame(width: 520, height: 580)
}
