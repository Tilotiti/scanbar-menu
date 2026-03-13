//
//  BarcodeDetector.swift
//  ScanBarMenu
//

import Foundation

struct BarcodeDetector {
    private let maxLength = 48

    /// Vérifie si le texte est potentiellement un code-barres (moins de 48 caractères).
    func isPotentialBarcode(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= maxLength
    }
}
