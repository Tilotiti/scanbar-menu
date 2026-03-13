//
//  ContentView.swift
//  ScanBarMenu
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ScanBar Menu")
                .font(.headline)

            Divider()

            Button("Quitter") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 160)
    }
}

#Preview {
    ContentView()
}
