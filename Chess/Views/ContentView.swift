//
//  ContentView.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/13/20.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var engineViewModel : EngineViewModel
    // If these aren't seperate, SwiftUI bugs out
    @State var isAwayFromMenuGame = false
    @State var isAwayFromMenuReview = false
    @State var isAwayFromMenuPreferences = false
    
    let toolTipContent = """

This is the main menu.

Play Game allows you to play a game of chess with a local friend.

Review Game showcases all archived games to be replayed.

Customize lets you change the colors and sounds of your chessboard.
"""
    
    var body: some View {
        
        NavigationView {
            GeometryReader { geometry in
                
                let innerButtonWidth = geometry.size.width * Constants.menuButtonWidthScaler
                let innerButtonHeight = innerButtonWidth * Constants.menuButtonHeightScaler
                ZStack {
                    
                    Constants.boardLightTile(settings: engineViewModel.settingsModel.settings)
                        .ignoresSafeArea()
                    
                    HStack {
                        Spacer()
                        
                        VStack {
                            Spacer()
                            NavigationLink(
                                destination: GameSetupView(isAwayFromMenu: $isAwayFromMenuGame),
                                isActive: $isAwayFromMenuGame,
                                label: { ModeButtonView(
                                    text: "Play Game",
                                    width: innerButtonWidth,
                                    height: innerButtonHeight
                                )}
                            )
                            .buttonStyle(PlainButtonStyle())
                            .onTapGesture {
                                isAwayFromMenuGame = true
                            }
                            Spacer()
                            
                            NavigationLink(
                                destination: AllGameView(isAwayFromMenu: $isAwayFromMenuReview),
                                isActive: $isAwayFromMenuReview,
                                label: { ModeButtonView(
                                    text: "Review Game",
                                    width: innerButtonWidth,
                                    height: innerButtonHeight
                                )}
                            )
                            .buttonStyle(PlainButtonStyle())
                            .onTapGesture {
                                isAwayFromMenuReview = true
                            }
                            Spacer()
                            
                            NavigationLink(
                                destination: PreferencesView(isAwayFromMenu: $isAwayFromMenuPreferences),
                                isActive: $isAwayFromMenuPreferences,
                                label: { ModeButtonView(
                                    text: "Customize",
                                    width: innerButtonWidth,
                                    height: innerButtonHeight
                                )}
                            )
                            .buttonStyle(PlainButtonStyle())
                            .onTapGesture {
                                isAwayFromMenuReview = true
                            }
                            Spacer()
                        }
                        Spacer()
                        
                        ToolTipView(showToolTip: $engineViewModel.settingsModel.settings.showMenuToolTip,
                                    content: toolTipContent)
                        
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("ChessApp")
                                .font(Font.custom("Righteous-Regular", size: Constants.titleFontSize))
                        }
                    }
                    .navigationTitle("Menu")
                    
                }
            }
        }
    }
}
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
