//
//  AppSettings.swift
//  ScanBarMenu
//

import AppKit
import Foundation

/// Format de code-barres ou QR proposé à l'utilisateur.
enum BarcodeFormat: String, CaseIterable, Identifiable {
    case code128 = "Code-128"
    case qrCode = "QR Code"
    case aztec = "Aztec"
    case pdf417 = "PDF417"

    var id: String { rawValue }

    /// Limite de caractères recommandée pour ce format.
    var recommendedMaxLength: Int {
        switch self {
        case .code128: return 80
        case .qrCode: return 4296
        case .aztec: return 3832
        case .pdf417: return 1850
        }
    }

    /// Ratio largeur:hauteur typique (largeur = 1).
    var aspectRatio: CGFloat {
        switch self {
        case .code128: return 3.75  // ~900/240
        case .qrCode, .aztec: return 1  // carré
        case .pdf417: return 2.5
        }
    }
}

/// Paramètres persistants de l'application.
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let format = "barcodeFormat"
        static let width = "barcodeWidth"
        static let patterns = "barcodePatterns"
        static let maxCharacterCountLegacy = "maxCharacterCount"
        static let panelOriginX = "panelOriginX"
        static let panelOriginY = "panelOriginY"
        static let saveFolderBookmark = "saveFolderBookmark"
        static let saveFolderDisplayName = "saveFolderDisplayName"
    }

    @Published var format: BarcodeFormat {
        didSet {
            defaults.set(format.rawValue, forKey: Keys.format)
        }
    }

    @Published var width: CGFloat {
        didSet {
            defaults.set(Double(width), forKey: Keys.width)
        }
    }

    @Published var patterns: [BarcodePattern] {
        didSet {
            persistPatterns()
        }
    }

    /// Dossier d'enregistrement choisi par l'utilisateur (via NSOpenPanel).
    /// Persisté sous forme de security-scoped bookmark.
    var saveFolderBookmark: Data? {
        get { defaults.data(forKey: Keys.saveFolderBookmark) }
        set {
            objectWillChange.send()
            defaults.set(newValue, forKey: Keys.saveFolderBookmark)
        }
    }

    /// Nom affiché du dossier (pour l'UI).
    var saveFolderDisplayName: String? {
        get { defaults.string(forKey: Keys.saveFolderDisplayName) }
        set {
            objectWillChange.send()
            defaults.set(newValue, forKey: Keys.saveFolderDisplayName)
        }
    }

    /// Position de la fenêtre du code-barres (persistée).
    var panelOrigin: NSPoint? {
        get {
            let x = defaults.double(forKey: Keys.panelOriginX)
            let y = defaults.double(forKey: Keys.panelOriginY)
            guard x != 0 || y != 0 else { return nil }
            return NSPoint(x: x, y: y)
        }
        set {
            if let p = newValue {
                defaults.set(p.x, forKey: Keys.panelOriginX)
                defaults.set(p.y, forKey: Keys.panelOriginY)
            } else {
                defaults.removeObject(forKey: Keys.panelOriginX)
                defaults.removeObject(forKey: Keys.panelOriginY)
            }
        }
    }

    /// Hauteur calculée en fonction du format et de la largeur.
    var height: CGFloat {
        width / format.aspectRatio
    }

    private init() {
        let formatRaw = UserDefaults.standard.string(forKey: Keys.format)
            ?? BarcodeFormat.code128.rawValue
        self.format = BarcodeFormat(rawValue: formatRaw) ?? .code128

        let storedWidth = UserDefaults.standard.double(forKey: Keys.width)
        self.width = storedWidth > 0 ? CGFloat(storedWidth) : 900

        let ud = UserDefaults.standard
        let (loaded, needsPersist) = Self.loadPatterns(from: ud)
        self.patterns = loaded
        if needsPersist {
            persistPatterns()
        }
    }

    private func persistPatterns() {
        if let data = try? JSONEncoder().encode(patterns) {
            defaults.set(data, forKey: Keys.patterns)
        }
    }

    /// - Returns: motifs à utiliser, et si les réglages doivent être réécrits (première install, migration ou données invalides).
    private static func loadPatterns(from defaults: UserDefaults) -> ([BarcodePattern], Bool) {
        if let data = defaults.data(forKey: Keys.patterns),
           let decoded = try? JSONDecoder().decode([BarcodePattern].self, from: data),
           !decoded.isEmpty {
            return (decoded, false)
        }
        let legacyMax = defaults.integer(forKey: Keys.maxCharacterCountLegacy)
        let limit = legacyMax > 0 ? min(legacyMax, 500) : 48
        return ([BarcodePattern(name: String(localized: "Global"), regex: "^.{1,\(limit)}$")], true)
    }

    func movePattern(id: UUID, direction: Int) {
        var next = patterns
        guard let index = next.firstIndex(where: { $0.id == id }) else { return }
        let newIndex = index + direction
        guard newIndex >= 0, newIndex < next.count else { return }
        next.swapAt(index, newIndex)
        patterns = next
    }

    func addPattern() {
        patterns.append(
            BarcodePattern(
                name: String(localized: "New pattern"),
                regex: "^.{1,80}$"
            )
        )
    }

    func removePatterns(at offsets: IndexSet) {
        var next = patterns
        next.remove(atOffsets: offsets)
        if next.isEmpty {
            next = [BarcodePattern(name: String(localized: "Global"), regex: "^.{1,80}$")]
        }
        patterns = next
    }

    func updatePattern(id: UUID, name: String? = nil, regex: String? = nil) {
        var next = patterns
        guard let i = next.firstIndex(where: { $0.id == id }) else { return }
        if let name { next[i].name = name }
        if let regex { next[i].regex = regex }
        patterns = next
    }
}
