//
//  DrawExpressionView.swift
//  Simpli
//
//  Created by Yohane Cavalcante on 06/08/26.
//

import SwiftUI
import PencilKit

struct DrawExpressionView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var drawing = PKDrawing()
    @State private var result: String = ""
    @State private var debugImage: UIImage?

    private let classifier = try? MathSymbolsClassifier()

    var body: some View {
        ZStack {
            Color(.secondarySystemBackground)
                .ignoresSafeArea()
            
            VStack {
                
                Text("Draw the expression you want to solve")
                    .font(.custom("ElmsSans-SemiBold", size: 18))
                    .foregroundColor(.primary)

                if !result.isEmpty {
                    Text("Recognized: \(result)")
                        .font(.custom("ElmsSans-Bold", size: 22))
                        .foregroundColor(.primary)
                }

                // Debug: shows the exact 28x28 image sent to the model, scaled
                
                if let debugImage {
                    Image(uiImage: debugImage)
                        .interpolation(.none)
                        .resizable()
                        .frame(width: 112, height: 112)
                        .border(Color("ButtonPink"), width: 2)
                }

                Spacer()
                
                CanvaView(drawing: $drawing)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("ButtonPink"), lineWidth: 5)
                    )
                    .padding(.vertical)
                
                Spacer()
                
                HStack {
                    Button("Clear") {
                        drawing = PKDrawing()
                        result = ""
                        debugImage = nil
                    }
                    .buttonStyle(GameButtonStyle())
                    
                    Button("Calculate") {
                        recognize()
                    }
                    .buttonStyle(GameButtonStyle())
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
            if let prediction = try classifier.classify(drawing) {
                result = "\(prediction.label) (\(Int(prediction.confidence * 100))%)"
                debugImage = prediction.inputImage
            } else {
                result = "Draw something first"
                debugImage = nil
            }
        } catch {
            result = "Error"
            debugImage = nil
        }
    }
}

#Preview {
    NavigationStack {
        DrawExpressionView()
    }
}
