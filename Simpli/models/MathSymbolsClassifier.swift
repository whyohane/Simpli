//
//  MathSymbolsClassifier.swift
//  Simpli
//
//  Created by Yohane Cavalcante on 10/08/26.
//

import CoreImage
import CoreML
import PencilKit
import UIKit

final class MathSymbolsClassifier {

    struct Prediction {
        let label: String
        let confidence: Double
        let inputImage: UIImage?
    }

    private let model: MathSymbols


    init() throws {
        model = try MathSymbols(configuration: MLModelConfiguration())
    }

    func classify(_ drawing: PKDrawing) throws -> Prediction? {
        guard let pixelBuffer = Self.makePixelBuffer(from: drawing) else { return nil }
        let output = try model.prediction(input_1: pixelBuffer)
        let confidence = output.classLabel_probs[output.classLabel] ?? 0
        return Prediction(
            label: output.classLabel,
            confidence: confidence,
            inputImage: Self.image(from: pixelBuffer)
        )
    }

    private static func image(from buffer: CVPixelBuffer) -> UIImage? {
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
        guard let base = CVPixelBufferGetBaseAddress(buffer),
              let context = CGContext(
                data: base,
                width: CVPixelBufferGetWidth(buffer),
                height: CVPixelBufferGetHeight(buffer),
                bitsPerComponent: 8,
                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                space: CGColorSpaceCreateDeviceGray(),
                bitmapInfo: CGImageAlphaInfo.none.rawValue
              ),
              let cgImage = context.makeImage() else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }

    // MARK: - Image preparation

    private static let inputSize = 28

    private static let fitSize: CGFloat = 20

    private static func makePixelBuffer(from drawing: PKDrawing) -> CVPixelBuffer? {
        let size = inputSize
        guard let rendered = renderNormalized(drawing, size: size) else { return nil }

        // Recenter by intensity-weighted center of mass, like MNIST.
        var total = 0.0, sumX = 0.0, sumY = 0.0
        for y in 0..<size {
            for x in 0..<size {
                let value = Double(rendered[y * size + x])
                total += value
                sumX += value * Double(x)
                sumY += value * Double(y)
            }
        }
        guard total > 0 else { return nil }
        let shiftX = Int((Double(size) / 2 - sumX / total).rounded())
        let shiftY = Int((Double(size) / 2 - sumY / total).rounded())

        // Copy the normalized pixels into the pixel buffer, applying the shift.
        let attrs: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ]
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault, size, size,
            kCVPixelFormatType_OneComponent8,
            attrs as CFDictionary, &pixelBuffer
        )
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        guard let base = CVPixelBufferGetBaseAddress(buffer) else { return nil }
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        let pixels = base.assumingMemoryBound(to: UInt8.self)

        for y in 0..<size {
            let sourceY = y - shiftY
            for x in 0..<size {
                let sourceX = x - shiftX
                let value: UInt8
                if sourceX >= 0, sourceX < size, sourceY >= 0, sourceY < size {
                    value = rendered[sourceY * size + sourceX]
                } else {
                    value = 0 // black background
                }
                pixels[y * bytesPerRow + x] = value
            }
        }

        return buffer
    }

    private static func renderNormalized(_ drawing: PKDrawing, size: Int) -> [UInt8]? {
        let strokeBounds = drawing.bounds
        guard !strokeBounds.isNull, strokeBounds.width > 0, strokeBounds.height > 0 else {
            return nil
        }
        
        var strokeImage: UIImage!
        UITraitCollection(userInterfaceStyle: .light).performAsCurrent {
            strokeImage = drawing.image(from: strokeBounds, scale: 4)
        }
        guard let cgImage = Self.cgImage(from: strokeImage) else { return nil }

        // Scale to fit the fit box while preserving aspect ratio.
        let scale = fitSize / max(strokeBounds.width, strokeBounds.height)
        let drawWidth = strokeBounds.width * scale
        let drawHeight = strokeBounds.height * scale
        let originX = (CGFloat(size) - drawWidth) / 2
        let originY = (CGFloat(size) - drawHeight) / 2

        var pixels = [UInt8](repeating: 0, count: size * size)
        let success: Bool = pixels.withUnsafeMutableBytes { raw in
            guard let base = raw.baseAddress,
                  let context = CGContext(
                    data: base,
                    width: size,
                    height: size,
                    bitsPerComponent: 8,
                    bytesPerRow: size,
                    space: CGColorSpaceCreateDeviceGray(),
                    bitmapInfo: CGImageAlphaInfo.none.rawValue
                  ) else {
                return false
            }

            // Black background.
            context.setFillColor(gray: 0, alpha: 1)
            context.fill(CGRect(x: 0, y: 0, width: size, height: size))
            context.interpolationQuality = .high

            // Draw the fitted, centered strokes. A raw bitmap context needs no
            // vertical flip here: the CGImage lands upright in the pixel memory.
            context.draw(cgImage, in: CGRect(x: originX, y: originY, width: drawWidth, height: drawHeight))
            return true
        }

        return success ? pixels : nil
    }

    private static let ciContext = CIContext()

    private static func cgImage(from image: UIImage) -> CGImage? {
        if let cgImage = image.cgImage {
            return cgImage
        }
        guard let ciImage = image.ciImage else { return nil }
        return ciContext.createCGImage(ciImage, from: ciImage.extent)
    }
}
