//
//  BarcodeDetector.swift
//  ScanBarMenu
//

import Foundation

struct BarcodeDetector {
    /// Vérifie si le texte est potentiellement un code-barres (longueur ≤ limite configurée).
    func isPotentialBarcode(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let limit = AppSettings.shared.maxCharacterCount
        return !trimmed.isEmpty && trimmed.count <= limit
    }
}
