//
//  SettingsView.swift
//  ScanBarMenu
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings

    private static let widthRange: ClosedRange<CGFloat> = 200 ... 1200
    private static let widthStep: CGFloat = 50
    private static let maxCharsRange = 10 ... 500
    private static let maxCharsStep = 5

    var body: some View {
        Form {
            // Format
            Section {
                Picker("Format", selection: Binding(
                    get: { settings.format },
                    set: { settings.format = $0 }
                )) {
                    ForEach(BarcodeFormat.allCases) { format in
                        Text(format.rawValue).tag(format)
                    }
                }
                .pickerStyle(.menu)
            } header: {
                Text("Format d'affichage")
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
                Text("Largeur (px)")
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
                Text("Limite de caractères max")
            } footer: {
                Text(String(localized: "Max recommandé pour \(settings.format.rawValue) : \(settings.format.recommendedMaxLength)"))
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

#Preview {
    SettingsView(settings: AppSettings.shared)
        .padding()
        .frame(width: 200)
}
