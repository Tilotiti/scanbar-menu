//
//  AboutView.swift
//  ScanBarMenu
//

import SwiftUI

struct AboutView: View {
    private static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.2.0"

    private static let licenseText = """
    Copyright (c) 2026 Thibault Henry

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    """

    var body: some View {
        VStack(spacing: 24) {
            // Logo de l'app
            if let appIcon = NSImage(named: NSImage.applicationIconName) {
                Image(nsImage: appIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 96, height: 96)
            }

            VStack(spacing: 4) {
                Text("ScanBar Menu")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Version \(Self.appVersion)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Auteur avec liens GitHub et LinkedIn
            VStack(spacing: 8) {
                Text(String(localized: "Développé par"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Thibault HENRY / Tilotiti")
                    .font(.body)

                HStack(spacing: 16) {
                    Link(
                        destination: URL(string: "https://github.com/Tilotiti")!,
                        label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left.forwardslash.chevron.right")
                                Text("GitHub")
                            }
                        }
                    )
                    Link(
                        destination: URL(string: "https://www.linkedin.com/in/tilotiti/")!,
                        label: {
                            HStack(spacing: 4) {
                                Image(systemName: "person.2.fill")
                                Text("LinkedIn")
                            }
                        }
                    )
                }
            }

            Divider()

            // Licence MIT
            VStack(alignment: .leading, spacing: 8) {
                Text("MIT License")
                    .font(.subheadline)
                    .fontWeight(.medium)

                ScrollView {
                    Text(Self.licenseText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(maxHeight: 140)
            }
        }
        .padding(24)
        .frame(minWidth: 360, minHeight: 400)
    }
}

#Preview {
    AboutView()
}
