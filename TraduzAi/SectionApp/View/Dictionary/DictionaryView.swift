//
//  DictionaryView.swift
//  TraduzAi
//
//  Created by Turma02-25 on 10/03/25.
//

import SwiftUI

struct DictionaryView: View {
    @StateObject private var viewModel = DictionaryViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color("BG")
                    .ignoresSafeArea()
                    .onTapGesture { hideKeyboard() }
                    .accessibilityLabel("Fundo da tela de dicionário") // Descrição básica do fundo

                VStack(spacing: 25) {
                    // HStack com menu de idioma e campo de entrada
                    HStack(spacing: 12) {
                        // Menu de seleção de idioma
                        Menu {
                            Button {
                                viewModel.selectedLanguage = "Português"
                                viewModel.searchWord = ""
                                viewModel.definition = ""
                            } label: {
                                Label("Português", image: "flag_pt")
                            }
                            Button {
                                viewModel.selectedLanguage = "Inglês"
                                viewModel.searchWord = ""
                                viewModel.definition = ""
                            } label: {
                                Label("Inglês", image: "flag_en")
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(viewModel.languageFlag)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .clipShape(Circle())
                                Text(viewModel.selectedLanguage)
                                    .foregroundColor(.black)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: .black.opacity(0.06), radius: 2, x: 0, y: 1)
                        }
                        .accessibilityLabel("Selecionar idioma: \(viewModel.selectedLanguage)")
                        .accessibilityHint("Toque para escolher entre Português e Inglês")
                        .accessibilityAddTraits(.isButton)

                        // Campo de entrada com ícone de lupa
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .accessibilityHidden(true) // Ícone decorativo, não precisa de descrição
                            TextField("Digite a palavra", text: $viewModel.searchWord)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .accessibilityLabel("Digite a palavra para pesquisar")
                                .accessibilityHint("Insira a palavra que deseja consultar no dicionário")
                        }
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: .black.opacity(0.06), radius: 2, x: 0, y: 1)
                    }
                    .padding(.horizontal, 16)

                    // Botão de pesquisa estilizado
                    Button(action: {
                        viewModel.fetchDefinition()
                    }) {
                        Text("Pesquisar")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("ICON"))
                            .cornerRadius(8)
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                    }
                    .accessibilityLabel("Pesquisar definição")
                    .accessibilityHint("Toque para buscar a definição da palavra inserida")
                    .accessibilityAddTraits(.isButton)
                    .padding(.horizontal, 16)

                    // Exibir o resultado (card com definição)
                    if viewModel.isLoading {
                        ProgressView("Buscando definição...")
                            .padding()
                            .accessibilityLabel("Buscando definição")
                            .accessibilityHint("Aguarde enquanto a definição está sendo carregada")
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                            .accessibilityLabel("Erro: \(error)")
                            .accessibilityHint("Ocorreu um problema ao buscar a definição")
                    } else if !viewModel.definition.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(viewModel.languageFlag)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .clipShape(Circle())
                                    .accessibilityHidden(true) // Ícone decorativo
                                Text(viewModel.selectedLanguage)
                                    .font(.headline)
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(.top, 16)
                            .padding(.horizontal, 16)
                            .accessibilityLabel("Idioma da definição: \(viewModel.selectedLanguage)")

                            Text(viewModel.searchWord)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 16)
                                .accessibilityLabel("Palavra pesquisada: \(viewModel.searchWord)")

                            Divider()
                                .padding(.horizontal, 16)
                                .accessibilityHidden(true) // Divisor decorativo

                            ScrollView {
                                Text(viewModel.definition)
                                    .font(.body)
                                    .foregroundColor(.black.opacity(0.8))
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 16)
                                    .accessibilityLabel("Definição")
                                    .accessibilityValue(viewModel.definition)
                                    .accessibilityHint("Definição da palavra pesquisada")
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        .accessibilityElement(children: .combine) // Combina os elementos internos em um único item acessível
                    }

                    Spacer()
                }
                .padding(.top, 10)
            }
            .navigationBarTitle("Dicionário", displayMode: .large)
            .accessibilityLabel("Tela do dicionário") // Rótulo para o título da navegação
        }
    }
}

struct DictionaryView_Previews: PreviewProvider {
    static var previews: some View {
        DictionaryView()
    }
}
