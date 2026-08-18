//
//  DrawExpressionViewModel.swift
//  Simpli
//
//  Created by Yohane Cavalcante on 18/08/26.
//

import Foundation
import PencilKit
import UIKit

@Observable
final class DrawExpressionViewModel {

    private(set) var result: String = ""
    private(set) var debugImages: [UIImage] = []

    private let classifier = try? MathSymbolsClassifier()

    func recognize(_ drawing: PKDrawing) {
        guard let classifier else {
            result = "Model unavailable"
            return
        }
        do {
            let predictions = try classifier.classifyExpression(drawing)
            guard !predictions.isEmpty else {
                result = "Draw something first"
                debugImages = []
                return
            }

            let expression = predictions.map(\.label).joined()
            if let value = Self.evaluate(expression) {
                result = "\(expression) = \(value)"
            } else {
                result = expression
            }

            // Show the normalized input of every recognized symbol for debugging.
            debugImages = predictions.compactMap(\.inputImage)

        } catch {
            result = "Error"
            debugImages = []
        }
    }

    func clear() {
        result = ""
        debugImages = []
    }

    private static func evaluate(_ expression: String) -> Int? {
        var result = 0
        var sign = 1
        var currentNumber = ""
        var hasNumber = false

        for character in expression {
            if character.isNumber {
                currentNumber.append(character)
                hasNumber = true
            } else if character == "+" || character == "-" {
                guard let number = Int(currentNumber) else { return nil }
                result += sign * number
                currentNumber = ""
                sign = character == "+" ? 1 : -1
            } else {
                return nil
            }
        }

        guard hasNumber, let number = Int(currentNumber) else { return nil }
        return result + sign * number
    }
}
