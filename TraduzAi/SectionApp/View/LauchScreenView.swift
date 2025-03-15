//
//  LauchScreenView.swift
//  TraduzAi
//
//  Created by Turma02-25 on 10/03/25.
//

import SwiftUI

struct LauchScreenView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            Lottie(animationFileName: "TraduzAi", loopMode: .loop)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
