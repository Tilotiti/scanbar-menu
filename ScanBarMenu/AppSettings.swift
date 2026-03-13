//
//  AppSettings.swift
//  ScanBarMenu
//

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
        static let maxCharacterCount = "maxCharacterCount"
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

    @Published var maxCharacterCount: Int {
        didSet {
            defaults.set(maxCharacterCount, forKey: Keys.maxCharacterCount)
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

        let storedMax = UserDefaults.standard.integer(forKey: Keys.maxCharacterCount)
        self.maxCharacterCount = storedMax > 0 ? storedMax : 48
    }
}
