//
//  ContentView.swift
//  Simpli
//
//  Created by Yohane Cavalcante on 05/08/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @State private var shouldShowDrawView: Bool = false
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                
                Text("Welcome to\nSimpli")
                    .font(.custom("ElmsSans-Bold", size: 50))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                CebrusView()
                
                Text("Let's solve some math expressions\n and have fun together!")
                    .multilineTextAlignment(.center)
                    .font(.custom("ElmsSans-SemiBold", size: 16))
                    .foregroundStyle(.primary)
                Spacer()
                Button ("Try now") {
                    
                    shouldShowDrawView = true
                    
                }
                .buttonStyle(GameButtonStyle())
                
            }
            .padding()
            .navigationDestination(isPresented: $shouldShowDrawView) {
                DrawExpressionView()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
