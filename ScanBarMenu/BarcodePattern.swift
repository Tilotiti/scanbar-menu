//
//  BarcodePattern.swift
//  ScanBarMenu
//

import Foundation

/// Motif utilisateur : nom affiché + expression régulière (correspondance sur toute la chaîne trimée).
struct BarcodePattern: Codable, Equatable, Identifiable, Hashable {
    var id: UUID
    var name: String
    /// Expression régulière ; la référence entière (sans espaces de bord) doit correspondre.
    var regex: String

    init(id: UUID = UUID(), name: String, regex: String) {
        self.id = id
        self.name = name
        self.regex = regex
    }
}

enum ClipboardPatternMatcher {
    /// Compile la regex ; en cas d’échec, retourne nil (motif ignoré à l’exécution).
    static func regularExpression(for pattern: String) -> NSRegularExpression? {
        let trimmed = pattern.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return try? NSRegularExpression(pattern: trimmed, options: [])
    }

    /// Indique si la chaîne entière correspond à la regex (une seule occurrence couvrant toute la plage).
    static func fullStringMatches(_ text: String, regex: NSRegularExpression) -> Bool {
        let ns = text as NSString
        let length = ns.length
        guard length > 0 else { return false }
        let range = NSRange(location: 0, length: length)
        guard let match = regex.firstMatch(in: text, options: [], range: range) else { return false }
        return match.range == range
    }

    static func matches(_ text: String, pattern: BarcodePattern) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let regex = regularExpression(for: pattern.regex) else { return false }
        return fullStringMatches(trimmed, regex: regex)
    }

    /// Premier motif de la liste qui correspond, selon l’ordre défini par l’utilisateur.
    static func firstMatchingPattern(for text: String, in patterns: [BarcodePattern]) -> BarcodePattern? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        for p in patterns {
            guard let regex = regularExpression(for: p.regex) else { continue }
            if fullStringMatches(trimmed, regex: regex) { return p }
        }
        return nil
    }

    /// Tous les motifs qui correspondent (pour l’outil de test).
    static func allMatchingPatterns(for text: String, in patterns: [BarcodePattern]) -> [BarcodePattern] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return patterns.filter { p in
            guard let regex = regularExpression(for: p.regex) else { return false }
            return fullStringMatches(trimmed, regex: regex)
        }
    }

    static func isValidRegex(_ pattern: String) -> Bool {
        let trimmed = pattern.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        return regularExpression(for: trimmed) != nil
    }
}
