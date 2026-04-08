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
    @State private var testReference: String = ""

    private static let widthRange: ClosedRange<CGFloat> = 200 ... 1200
    private static let widthStep: CGFloat = 50

    var body: some View {
        NavigationStack {
            formContent
        }
    }

    private var formContent: some View {
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

            Section {
                ForEach(settings.patterns) { pattern in
                    patternRow(pattern)
                }

                Button {
                    settings.addPattern()
                } label: {
                    Label(String(localized: "Add pattern"), systemImage: "plus.circle.fill")
                }
            } header: {
                Text(String(localized: "Clipboard patterns"))
            } footer: {
                Text(String(localized: "Patterns are tested top to bottom; the first match is used. The whole copied text (trimmed) must match the regex. Example: ^[0-9A-Z]{8,20}$"))
            }

            Section {
                TextField(String(localized: "Reference to test"), text: $testReference)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))

                Group {
                    Text(patternTestSummary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } header: {
                Text(String(localized: "Test a reference"))
            } footer: {
                Text(String(localized: "Shows which pattern matches first and all other matching patterns."))
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

    private var patternTestSummary: String {
        let trimmed = testReference.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return String(localized: "Enter a reference to test.")
        }
        if settings.patterns.isEmpty {
            return String(localized: "No patterns configured.")
        }
        guard let first = ClipboardPatternMatcher.firstMatchingPattern(for: trimmed, in: settings.patterns) else {
            return String(localized: "No pattern matches this reference.")
        }
        let all = ClipboardPatternMatcher.allMatchingPatterns(for: trimmed, in: settings.patterns)
        let firstPart = String(localized: "First matching pattern:") + " " + first.name
        let others = all.filter { $0.id != first.id }
        if others.isEmpty {
            return firstPart
        }
        let names = others.map(\.name).joined(separator: ", ")
        return firstPart + "\n" + String(localized: "Also matches:") + " " + names
    }

    private func patternRow(_ pattern: BarcodePattern) -> some View {
        let index = settings.patterns.firstIndex(where: { $0.id == pattern.id }) ?? 0
        let count = settings.patterns.count
        return HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                TextField(String(localized: "Name"), text: Binding(
                    get: { settings.patterns.first { $0.id == pattern.id }?.name ?? "" },
                    set: { settings.updatePattern(id: pattern.id, name: $0) }
                ))
                TextField(String(localized: "Regular expression"), text: Binding(
                    get: { settings.patterns.first { $0.id == pattern.id }?.regex ?? "" },
                    set: { settings.updatePattern(id: pattern.id, regex: $0) }
                ))
                .font(.system(.body, design: .monospaced))

                if let live = settings.patterns.first(where: { $0.id == pattern.id }) {
                    if !live.regex.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                       !ClipboardPatternMatcher.isValidRegex(live.regex) {
                        Text(String(localized: "Invalid regular expression"))
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 2) {
                Button {
                    settings.movePattern(id: pattern.id, direction: -1)
                } label: {
                    Image(systemName: "chevron.up")
                }
                .buttonStyle(.borderless)
                .disabled(index == 0)

                Button {
                    settings.movePattern(id: pattern.id, direction: 1)
                } label: {
                    Image(systemName: "chevron.down")
                }
                .buttonStyle(.borderless)
                .disabled(index >= count - 1)

                Button(role: .destructive) {
                    if let idx = settings.patterns.firstIndex(where: { $0.id == pattern.id }) {
                        settings.removePatterns(at: IndexSet(integer: idx))
                    }
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
                .disabled(count <= 1)
            }
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

}

#Preview {
    SettingsView(settings: AppSettings.shared)
        .padding()
        .frame(width: 200)
}
