//
//  GameSetupView.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/16/20.
//

import SwiftUI

struct GameSetupView: View {
    @EnvironmentObject var engineViewModel : EngineViewModel
    @Binding var isAwayFromMenu: Bool
    @State var player1 : String = "Player 1"
    @State var player2 : String = "Player 2"
    @State var timeControl : Int?
    
    let toolTipContent = """

Here is Game Setup.

Choose a name for player 1 (white) and player 2 (black).

Then choose a time control and hit play to get started!
"""
    
    var body: some View {
        // Untimed, 5 mins, 10 mins, 30 mins, 1 hour
        let allTimeControls : [Int?] = [nil, 5 * 60, 10 * 60, 30 * 60, 60 * 60]
        
        VStack {
            Form {
                Section(header: Text("Name of Player 1: ")) {
                    TextField("Player 1", text: $player1, onEditingChanged: { _ in })
                }
                Section(header: Text("Name of Player 2: ")) {
                    TextField("Player 2", text: $player2, onEditingChanged: { _ in })
                }
                
                Section(header: Text("Time Control")) {
                    Picker("\(engineViewModel.timeControlText(time: timeControl))", selection: $timeControl) {
                        ForEach(allTimeControls, id: \.self) { time in
                            PickerButton(content:
                                            engineViewModel.timeControlText(time: time))
                                .fixedSize()
                                .frame(alignment:.center)
                        }
                    }.pickerStyle(MenuPickerStyle())
                }
                
                NavigationLink(
                    destination: PlayGameView(isAwayFromMenu: $isAwayFromMenu,
                                              allMoves: engineViewModel.allValidMoves(board: EngineViewModel.boardStartingPosition,
                                                                                      notation: [],
                                                                                      currentSide: .white),
                                              player1: player1,
                                              player2: player2,
                                              player1Time: timeControl,
                                              player2Time: timeControl,
                                              timeControl: timeControl),
                    label: {
                        Text("Play!")
                            .foregroundColor(.accentColor)
                    }).disabled(player1.isEmpty || player2.isEmpty)
            }
            
            ToolTipView(showToolTip: $engineViewModel.settingsModel.settings.showGameSetupToolTip,
                        content: toolTipContent)
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Game Setup")
        .toolbar {
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    isAwayFromMenu = false
                }) {
                    Text("Menu")
                }
                
            }
        }
    }
}

//struct GameSetupView_Previews: PreviewProvider {
//    static var previews: some View {
//        GameSetupView()
//    }
//}
