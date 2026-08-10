//
//  ButtonStyle.swift
//  Simpli
//
//  Created by Yohane Cavalcante on 06/08/26.
//

import SwiftUI

struct GameButtonStyle: ButtonStyle {
    var faceColor: Color = Color("ButtonPink")
    var deepColor: Color = Color("ButtonBackground")
    var borderColor: Color = Color("ButtonBorder")
    
    let feedback = UIImpactFeedbackGenerator(style: .soft)
    @Environment(\.isEnabled) private var isEnabled
    
    private let borderWidth: CGFloat = 7
    private let lipHeight: CGFloat = 6
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Borda externa
            Capsule()
                .fill(borderColor)
                .shadow(radius: 1, x: 0, y: 2)
            
            // Cor principal
            Capsule()
                .fill(isEnabled ? deepColor : deepColor)
                .padding(borderWidth)
            
            // Face do botão
            Capsule()
                .fill(isEnabled ? faceColor: faceColor)
                .padding(borderWidth)
                .shadow(color: .white.opacity(0.3), radius: 0, x: 0, y: 4)
                .overlay(
                    configuration.label
                        .foregroundColor(isEnabled ? .white : .white)
                            .font(.custom("ElmsSans-Bold", size: 20))
                )
                .offset(y: configuration.isPressed ? 0 : -lipHeight * 1.6)
        }
        .frame(height: 60)
        .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
        .onChange(of: configuration.isPressed) { _, isPressed in
            if isPressed {
                feedback.impactOccurred()
            }
        }
    }
}
   
#Preview {
    Button("Continue") {

    }
    .font(.custom("ElmsSans-Bold", size: 20))
    .frame(maxWidth: .infinity)
    .buttonStyle(GameButtonStyle())
    .padding(.horizontal, 24)
}
