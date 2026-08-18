//
//  DrawExpressionView.swift
//  Simpli
//
//  Created by Yohane Cavalcante on 06/08/26.
//

import SwiftUI
import PencilKit
import SwiftData

struct DrawExpressionView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var drawing = PKDrawing()
    @State private var result: String = ""
    @State private var debugImages: [UIImage] = []
    
    private let classifier = try? MathSymbolsClassifier()
    
    var body: some View {
        ZStack {
            Color(.secondarySystemBackground)
                .ignoresSafeArea()
            
            VStack {
                
                Text("Draw the expression you want to solve")
                    .font(.custom("ElmsSans-SemiBold", size: 18))
                    .foregroundColor(.primary)
                
                CanvaView(drawing: $drawing)
                    .frame(height: 480)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("ButtonPink"), lineWidth: 5)
                    )
                    .padding(.vertical)
                
                HStack {
                    Button("Clear") {
                        drawing = PKDrawing()
                        result = ""
                        debugImages = []
                    }
                    .buttonStyle(GameButtonStyle())
                    
                    Button("Calculate") {
                        recognize()
                    }
                    .buttonStyle(GameButtonStyle())
                    
                }
                Spacer()
                if !result.isEmpty {
                    Text("Recognized Expression: \(result)")
                        .font(.custom("ElmsSans-Bold", size: 18))
                        .foregroundColor(.primary)
                }
                
                // Debug: shows the exact 28x28 image sent to the model for each
                // segmented character, scaled up.
                if !debugImages.isEmpty {
                    HStack {
                        ForEach(Array(debugImages.enumerated()), id: \.offset) { _, image in
                            Image(uiImage: image)
                                .interpolation(.none)
                                .resizable()
                                .frame(width: 45, height: 45)
                                .border(Color("ButtonPink"), width: 2)
                        }
                    }
                }
            }
            
            .padding()
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Simpli")
                        .font(.custom("ElmsSans-Bold", size: 18))
                        .foregroundStyle(.primary)
                    
                }
            }
        }
    }
    
    private func recognize() {
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


#Preview {
    NavigationStack {
        DrawExpressionView()
    }
}
