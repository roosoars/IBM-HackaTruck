//
//  Extension+View.swift
//  TraduzAi
//
//  Created by Turma02-25 on 10/03/25.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

