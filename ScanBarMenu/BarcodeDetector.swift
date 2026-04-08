//
//  BarcodeDetector.swift
//  ScanBarMenu
//

import Foundation

struct BarcodeDetector {
    /// Vérifie si le texte correspond à au moins un motif configuré.
    func isPotentialBarcode(_ text: String) -> Bool {
        ClipboardPatternMatcher.firstMatchingPattern(for: text, in: AppSettings.shared.patterns) != nil
    }

    /// Motif reconnu pour ce texte, si applicable.
    func matchingPattern(for text: String) -> BarcodePattern? {
        ClipboardPatternMatcher.firstMatchingPattern(for: text, in: AppSettings.shared.patterns)
    }
}
