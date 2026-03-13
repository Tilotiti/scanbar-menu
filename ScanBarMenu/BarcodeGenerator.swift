//
//  BarcodeGenerator.swift
//  ScanBarMenu
//

import AppKit
import CoreImage.CIFilterBuiltins

enum BarcodeGenerator {
    private static let context = CIContext()

    /// Génère une image du format demandé à partir du texte, ou nil si la génération échoue.
    static func generate(from text: String, format: BarcodeFormat, width: CGFloat, height: CGFloat) -> NSImage? {
        guard let outputImage = createCIImage(from: text, format: format) else { return nil }

        let scaleX = width / outputImage.extent.width
        let scaleY = height / outputImage.extent.height
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return NSImage(cgImage: cgImage, size: NSSize(width: width, height: height))
    }

    /// Rétrocompatibilité : génère un Code-128 avec les dimensions par défaut.
    static func generateCode128(from text: String, width: CGFloat = 900, height: CGFloat = 240) -> NSImage? {
        generate(from: text, format: .code128, width: width, height: height)
    }

    private static func createCIImage(from text: String, format: BarcodeFormat) -> CIImage? {
        let data = Data(text.utf8)

        switch format {
        case .code128:
            let filter = CIFilter.code128BarcodeGenerator()
            filter.message = data
            filter.barcodeHeight = Float(140)
            filter.quietSpace = 20
            return filter.outputImage

        case .qrCode:
            let filter = CIFilter.qrCodeGenerator()
            filter.message = data
            filter.correctionLevel = "M"
            return filter.outputImage

        case .aztec:
            guard let filter = CIFilter(name: "CIAztecCodeGenerator") else { return nil }
            filter.setValue(data, forKey: "inputMessage")
            return filter.outputImage

        case .pdf417:
            guard let filter = CIFilter(name: "CIPDF417BarcodeGenerator") else { return nil }
            filter.setValue(data, forKey: "inputMessage")
            return filter.outputImage
        }
    }
}
