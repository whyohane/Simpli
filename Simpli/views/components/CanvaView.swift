//
//  CanvaView.swift
//  Simpli
//
//  Created by Yohane Cavalcante on 10/08/26.
//

import SwiftUI
import PencilKit

struct CanvaView: UIViewRepresentable {

    @Binding var drawing: PKDrawing

    var toolColor: UIColor = .white
    var toolWidth: CGFloat = 25

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.drawingPolicy = .anyInput


        canvasView.tool = PKInkingTool(.pen, color: toolColor, width: toolWidth)

        canvasView.backgroundColor = .black
        canvasView.isOpaque = true

        // PencilKit inverts ink colors in dark mode for contrast. Forcing light
        // mode makes it use the tool color exactly as given, so a white pen
        // stays white on the explicitly black background.
        canvasView.overrideUserInterfaceStyle = .light

        canvasView.drawing = drawing
        canvasView.delegate = context.coordinator

        return canvasView
    }

    func updateUIView(_ canvasView: PKCanvasView, context: Context) {
        // Keep the fixed tool in sync in case the color or width changes.
        canvasView.tool = PKInkingTool(.pen, color: toolColor, width: toolWidth)

        // Reflect external drawing changes (for example, clearing the canvas).
        if canvasView.drawing != drawing {
            canvasView.drawing = drawing
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        private let parent: CanvaView

        init(_ parent: CanvaView) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }
    }
}
