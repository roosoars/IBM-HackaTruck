//
//  TabBarView.swift
//  TraduzAi
//
//  Created by Turma02-25 on 10/03/25.
//

import SwiftUI

struct TabBarView: View {
    @State var selection: Int = 1
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        
        UITabBar.appearance().layer.shadowColor = UIColor.black.cgColor
        UITabBar.appearance().layer.shadowOpacity = 0.3
        UITabBar.appearance().layer.shadowOffset = CGSize(width: 0, height: 3)
        UITabBar.appearance().layer.shadowRadius = 3
        UITabBar.appearance().clipsToBounds = false
    }
    
    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Image(selection == 1 ? "TRANSLATOR_OUTLINE" : "TRANSLATOR")
                    Text("Inicio")
                }
                .tag(1)
            
            VoiceTranslatorView()
                .tabItem {
                    Image(selection == 2 ? "MICROPHONE_OUTLINE" : "MICROPHONE")
                    Text("Áudio")
                }
                .tag(2)
            
            HistoryView()
                .tabItem {
                    Image(selection == 3 ? "DICTIONARY_OUTLINE" : "DICTIONARY")
                    Text("Histórico")
                }
                .tag(3)
            
            DictionaryView()
                .tabItem {
                    Image(selection == 4 ? "DICTIONARY_OUTLINE" : "DICTIONARY")
                    Text("Dicionário")
                }
                .tag(4)
        }
    }
}
