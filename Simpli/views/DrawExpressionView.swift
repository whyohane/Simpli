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
    
    var body: some View {
        
        VStack {

            Text("Draw the expression you want to solve")
                .font(.custom("ElmsSans-SemiBold", size: 18))
                .foregroundColor(.primary)

            Spacer()

            Button ("Calculate") {


            }
            .buttonStyle(GameButtonStyle())

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

#Preview {
    NavigationStack {
        DrawExpressionView()
    }
}
