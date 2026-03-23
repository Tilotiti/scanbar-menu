//
//  SettingsView.swift
//  ScanBarMenu
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @State private var showFolderPicker = false

    private static let widthRange: ClosedRange<CGFloat> = 200 ... 1200
    private static let widthStep: CGFloat = 50
    private static let maxCharsRange = 10 ... 500
    private static let maxCharsStep = 5

    var body: some View {
        Form {
            // Dossier d'enregistrement
            Section {
                if let name = settings.saveFolderDisplayName {
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundStyle(.secondary)
                        Text(name)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer()
                        Button(String(localized: "Change")) {
                            showFolderPicker = true
                        }
                        Button(String(localized: "Clear"), role: .destructive) {
                            settings.saveFolderBookmark = nil
                            settings.saveFolderDisplayName = nil
                        }
                    }
                } else {
                    Button {
                        showFolderPicker = true
                    } label: {
                        Label(String(localized: "Choose save folder"), systemImage: "folder.badge.plus")
                    }
                }
            } header: {
                Text(String(localized: "Save folder"))
            } footer: {
                Text(String(localized: "Where to save generated images."))
            }

            // Format
            Section {
                Picker(String(localized: "Format"), selection: Binding(
                    get: { settings.format },
                    set: { settings.format = $0 }
                )) {
                    ForEach(BarcodeFormat.allCases) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .pickerStyle(.menu)
            } header: {
                Text(String(localized: "Display format"))
            }

            // Largeur
            Section {
                HStack {
                    Slider(
                        value: Binding(
                            get: { settings.width },
                            set: { settings.width = $0 }
                        ),
                        in: Self.widthRange,
                        step: Self.widthStep
                    )
                    Text("\(Int(settings.width)) px")
                        .font(.body.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(width: 60, alignment: .trailing)
                }
            } header: {
                Text(String(localized: "Width (px)"))
            }

            // Limite de caractères
            Section {
                HStack {
                    Slider(
                        value: Binding(
                            get: { Double(settings.maxCharacterCount) },
                            set: {
                                let value = Int($0.rounded())
                                settings.maxCharacterCount = min(max(value, Self.maxCharsRange.lowerBound), Self.maxCharsRange.upperBound)
                            }
                        ),
                        in: Double(Self.maxCharsRange.lowerBound) ... Double(Self.maxCharsRange.upperBound),
                        step: Double(Self.maxCharsStep)
                    )
                    Text("\(settings.maxCharacterCount)")
                        .font(.body.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(width: 40, alignment: .trailing)
                }
            } header: {
                Text(String(localized: "Max character limit"))
            } footer: {
                Text(String(localized: "Max recommended for \(settings.format.rawValue): \(settings.format.recommendedMaxLength)"))
            }
        }
        .formStyle(.grouped)
        .padding()
        .fileImporter(
            isPresented: $showFolderPicker,
            allowedContentTypes: [.directory],
            onCompletion: { result in
                guard case .success(let url) = result else { return }
                guard url.startAccessingSecurityScopedResource() else { return }
                defer { url.stopAccessingSecurityScopedResource() }
                do {
                    let bookmark = try url.bookmarkData(
                        options: .withSecurityScope,
                        includingResourceValuesForKeys: nil,
                        relativeTo: nil
                    )
                    settings.saveFolderBookmark = bookmark
                    settings.saveFolderDisplayName = url.lastPathComponent
                } catch { }
            }
        )
        .onDisappear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let configTitle = String(localized: "Configuration")
                if !NSApp.windows.contains(where: { $0.title == configTitle }) {
                    NSApp.setActivationPolicy(.accessory)
                }
            }
        }
    }

}

#Preview {
    SettingsView(settings: AppSettings.shared)
        .padding()
        .frame(width: 200)
}
