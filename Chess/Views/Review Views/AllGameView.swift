//
//  AllGameView.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/20/20.
//

import SwiftUI

struct AllGameView: View {
    @EnvironmentObject var engineViewModel : EngineViewModel
    @Binding var isAwayFromMenu : Bool
    
    let toolTipContent = """

This is the Game Review archive.

Every game you complete will be stored here for future reference.

Tap a game to replay through it!.
"""
    
    var body: some View {
        
        // Hold the previous / next button to skip to the front or end
        GeometryReader { geometry in // necessary to do this here or VStack will get messed up
            
            VStack {
                if engineViewModel.engineModel.allGames.isEmpty {
                    Spacer()
                    HStack {
                        Spacer()
                        ScaledTextView(content: "Play a game to review!",
                                       width: geometry.size.width * Constants.allGameDefaultTextWidthScaler,
                                       height: geometry.size.height * Constants.allGameDefaultTextHeightScaler)
                        Spacer()
                    }
                    
                    Spacer()
                }
                else {
                    List {
                        ForEach(engineViewModel.engineModel.dateTitles().reversed(), id: \.self) { sectionTitle in
                            Section(header: Text(engineViewModel.engineModel.dateHashText(dateHash: sectionTitle))) {
                                ForEach(engineViewModel.engineModel.dateIndices(filterDateHash: sectionTitle), id: \.self) { i in
                                    let currentGame = engineViewModel.engineModel.allGames[i]
                                    NavigationLink(destination:
                                                    GameReviewView(board: EngineViewModel.boardStartingPosition,
                                                                   currentGame: currentGame),
                                                   label: {
                                                    GameTagView(game: currentGame)
                                                   })
                                }
                            }
                        }
                    }
                }
                
                ToolTipView(showToolTip: $engineViewModel.settingsModel.settings.showGameReviewToolTip,
                            content: toolTipContent)
                
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Games")
        .toolbar {
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    isAwayFromMenu = false
                }) {
                    Text("Menu")
                        .font(.largeTitle)
                }
            }
        }
    }
}

//struct ReviewGameView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReviewGameView()
//    }
//}
