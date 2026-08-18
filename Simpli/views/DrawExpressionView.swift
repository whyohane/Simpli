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
    @State private var viewModel = DrawExpressionViewModel()

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
                        viewModel.clear()
                    }
                    .buttonStyle(GameButtonStyle())

                    Button("Calculate") {
                        viewModel.recognize(drawing)
                    }
                    .buttonStyle(GameButtonStyle())

                }
                Spacer()
                if !viewModel.result.isEmpty {
                    Text("Recognized Expression: \(viewModel.result)")
                        .font(.custom("ElmsSans-Bold", size: 18))
                        .foregroundColor(.primary)
                }
                
                // Debug: shows the exact 28x28 image sent to the model for each
                // segmented character, scaled up.
                if !viewModel.debugImages.isEmpty {
                    HStack {
                        ForEach(Array(viewModel.debugImages.enumerated()), id: \.offset) { _, image in
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
}


#Preview {
    NavigationStack {
        DrawExpressionView()
    }
}
