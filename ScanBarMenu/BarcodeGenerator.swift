//
//  BarcodeGenerator.swift
//  ScanBarMenu
//

import AppKit
import CoreImage.CIFilterBuiltins

enum BarcodeGenerator {
    private static let context = CIContext()

    /// Génère une image Code-128 à partir du texte, ou nil si la génération échoue.
    static func generateCode128(from text: String, width: CGFloat = 450, height: CGFloat = 120) -> NSImage? {
        let filter = CIFilter.code128BarcodeGenerator()
        filter.message = Data(text.utf8)
        filter.barcodeHeight = Float(height * 0.6)
        filter.quietSpace = 10

        guard let outputImage = filter.outputImage else { return nil }

        // Mise à l'échelle pour une meilleure lisibilité
        let scaleX = width / outputImage.extent.width
        let scaleY = height / outputImage.extent.height
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return NSImage(cgImage: cgImage, size: NSSize(width: width, height: height))
    }
}
