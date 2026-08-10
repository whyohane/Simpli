//
//  CebrusView.swift
//  Simpli
//
//  Created by Yohane Cavalcante on 06/08/26.
//

import SwiftUI

struct CebrusView: View {
    
    var scale: CGFloat = 1

    @State private var isFloating = false
    @State private var isBlinking = false
    @State private var isWaving = false

    var body: some View {
        ZStack {
            Image("blackboard")
                .offset(x: 90, y: -156)
            
            Image("cebrus-arm")
                .rotationEffect(.degrees(isWaving ? 12 : -12), anchor: .bottom)
                .offset(x: 85, y:-50)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isWaving)
            
            Image("cebrus")
                .offset(x: -30)
            
            Image("cebrus-left-eye")
                .scaleEffect(y: isBlinking ? 0.08 : 1, anchor: .center)
                .offset(x: -90, y: 5)
                .animation(.easeInOut(duration: 0.08), value: isBlinking)

            Image("cebrus-right-eye")
                .scaleEffect(y: isBlinking ? 0.08 : 1, anchor: .center)
                .offset(x: 0, y: 5)
                .animation(.easeInOut(duration: 0.08), value: isBlinking)

            Image("cebrus-cheeks")
                .offset(x:-45, y: 30)

        }

        .frame(maxWidth: .infinity)
        .onAppear {
            isFloating = true
            isWaving = true
        }
        .task {
            await blinkEyes()
        }
    }
    private func blinkEyes() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(2))
            isBlinking = true
            try? await Task.sleep(for: .milliseconds(120))
            isBlinking = false
        }
    }
}

#Preview {
    CebrusView()
}
