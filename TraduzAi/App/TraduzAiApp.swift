//
//  TraduzAiApp.swift
//  TraduzAi
//
//  Created by Turma02-25 on 10/03/25.
//

import SwiftUI

@main
struct MyApp: App {
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                TabBarView()
                
                if showSplash {
                    LauchScreenView()
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    showSplash = false
                                }
                            }
                        }
                }
            }
        }
    }
}
