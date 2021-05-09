//
//  PlayGameView.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/15/20.
//

import SwiftUI
import AVFoundation

struct PlayGameView: View {
    @EnvironmentObject var engineViewModel : EngineViewModel
    @Binding var isAwayFromMenu : Bool
    @State var board : ChessBoard = EngineViewModel.boardStartingPosition
    @State var notation : MoveList = []
    @State var navigatingAway = false
    @State var isGameOver = false
    @State var currentSoundEffect: AVAudioPlayer? = nil
    @State var currentDate = Date()
    
    @State var allMoves : MoveList
    
    let player1 : String
    let player2 : String
    @State var player1Time : Int?
    @State var player2Time : Int?
    
    let timeControl : Int?
    
    var currentSide : Side { engineViewModel.currentSideByNotation(notation: notation) }
    
    var currentPlayer : String { currentSide == .white ? player1 : player2 }
    var oppositePlayer : String { currentSide == .white ? player2 : player1 }
    
    var currentTime : Int? { currentSide == .white ? player1Time : player2Time }
    var oppositeTime : Int? { currentSide == .white ? player2Time : player1Time }
    
    var currentTimeText : String { engineViewModel.timeControlText(time: currentTime) }
    var oppositeTimeText : String { engineViewModel.timeControlText(time: oppositeTime) }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect() // (1)
    
    let toolTipContent = """

Now you are in a match with your opponent!

Get ready to start playing.

Tap on any of your pieces to see all legal moves, and then tap again on the board on one of the highlighted squares to move that piece to that location! Then, hand over your device to your opponent so they can make their move.

If a move involves a pawn promotion, tap on the promotion square once more to choose a promotion piece.

When the game is over (by checkmate, time, or draw), the game will be sent to the Game Review archive for future review.
"""
    
    var body: some View {
        GeometryReader { geometry in // necessary to do this here or VStack will get messed up
            let squareSize = geometry.size.width / CGFloat(Constants.squaresLimit)
            
            VStack(spacing: 0) {
                
                HStack {
                    Spacer()
                    HStack(spacing: 0) {
                        ScaledTextView(content: "\(oppositePlayer)",
                                       height: squareSize * Constants.playGameCurrentPlayerTextScaler)
                    }
                    if oppositeTimeText != "Untimed" {
                        HStack(spacing: 0) {
                            ScaledTextView(content: " | ",
                                           height: squareSize * Constants.playGameCurrentPlayerTextScaler)
                            ScaledTextView(content: "\(oppositeTimeText)",
                                           height: squareSize * Constants.playGameCurrentPlayerTextScaler)
                                .foregroundColor(timeColor(oppositeTime))
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                ScaledTextView(content: "\(currentPlayer)'s Turn!",
                               height: squareSize)
                
                ZStack {
                    BoardView(board: $board,
                              notation: $notation,
                              isGameOver: $isGameOver,
                              allMoves: $allMoves,
                              squareSize: squareSize,
                              playSound: playSound)
                    
                    RankView(currentSide: currentSide,
                             squareSize: squareSize)
                    
                    FileView(squareSize: squareSize)
                }
                
                Spacer()
                VStack {
                    Spacer()
                    ScaledTextView(content: "\(currentTimeText) / \(engineViewModel.timeControlText(time: timeControl))",
                                   height: squareSize * Constants.playGameCurrentPlayerTextScaler)
                        .foregroundColor(timeColor(currentTime))
                        .onReceive(timer) {_ in
                            if timeControl != nil && !isGameOver && !engineViewModel.settingsModel.settings.showPlayGameToolTip {
                                if currentSide == .white && player1Time! > 0 {
                                    player1Time! -= 1
                                }
                                else if player2Time! > 0 {
                                    player2Time! -= 1
                                }
                                if player1Time == 0 || player2Time == 0 {
                                    isGameOver = true
                                    playSound(soundLocation: engineViewModel.settingsModel.settings.checkmateSound)
                                }
                            }
                        }
                    Spacer()
                }.opacity(currentTimeText != "Untimed" ? 1 : 0)
                
            }
            .alert(isPresented: $isGameOver) { () -> Alert in
                let playedGame = Game(id: UUID(),
                                      player1: player1,
                                      player2: player2,
                                      datePlayed: currentDate,
                                      timeLimit: timeControl,
                                      timeRemainingPlayer1: player1Time,
                                      timeRemainingPlayer2: player2Time,
                                      notation: notation)
                
                let leaveButton = Alert.Button.default(Text("Menu")) {
                    if notation.last != nil {
                        engineViewModel.engineModel.allGames.append(playedGame)
                    }
                    isAwayFromMenu = false
                }
                let rematchButton = Alert.Button.default(Text("Rematch!")) {
                    if notation.last != nil {
                        engineViewModel.engineModel.allGames.append(playedGame)
                    }
                    board = EngineViewModel.boardStartingPosition
                    notation = []
                    allMoves = engineViewModel.allValidMoves(board: board,
                                                             notation: notation,
                                                             currentSide: currentSide)
                    player1Time = timeControl
                    player2Time = timeControl
                    currentDate = Date()
                    isGameOver = false
                    
                }
                return Alert(title: Text("Game Over!"),
                             message: Text(gameOverText(game: notation)),
                             primaryButton: leaveButton,
                             secondaryButton: rematchButton)
            }
            
            ToolTipView(showToolTip: $engineViewModel.settingsModel.settings.showPlayGameToolTip,
                        content: toolTipContent)
            
            // This empty button is dumb but necessary, otherwise I get buggy behaviour.
            Button(action: {}) { EmptyView() }
                .alert(isPresented: $navigatingAway) { () -> Alert in
                    let leaveButton = Alert.Button.default(Text("Leave")) {
                        isAwayFromMenu = false
                    }
                    let resumeButton = Alert.Button.default(Text("Resume")) {}
                    return Alert(title: Text("Back to Main Menu"),
                                 message: Text("Are you sure you want to leave? This game will not be stored."),
                                 primaryButton: leaveButton,  secondaryButton: resumeButton)
                }
                
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            navigatingAway = true
                        }) {
                            Text("Menu")
                                .font(Font.custom("Righteous-Regular", size: 30))
                        }
                    }
                }
            
        }
    }
    func gameOverText(game: MoveList) -> String {
        
        if let move = game.last {
            // Game will checkmate on the losers turn
            if move.checkmate {
                return "\(oppositePlayer) has checkmated \(currentPlayer)!"
            }
            
            else if timeControl != nil {
                if player1Time! == 0 {
                    return "\(player2) has beaten \(player1) on time!"
                }
                else if player2Time! == 0 {
                    return "\(player1) has beaten \(player2) on time!"
                }
            }
            
            if move.draw! == .stalemate {
                return "Stalemate! \(oppositePlayer) and \(currentPlayer) have drawn!"
            }
            else if move.draw! == .repetition {
                return "Threefold Repetition! \(oppositePlayer) and \(currentPlayer) have drawn!"
            }
            else if move.draw! == .insufficientMaterial {
                return "Insufficient material left for checkmate! \(oppositePlayer) and \(currentPlayer) have drawn!"
            }
            else {
                return "ERROR"
            }
        }
        else {
            return "No moves have been made. Game will not be recorded."
        }
    }
    
    func timeColor(_ currentTime: Int?) -> Color {
        if let unwrappedTime = currentTime {
            if unwrappedTime < 30 {
                return .red
            }
        }
        return .black
    }
    
    func playSound(soundLocation: String?) {
        if let soundFilename = soundLocation {
            let path = Bundle.main.path(forResource: soundFilename, ofType:"mp3")
            
            do {
                currentSoundEffect = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path!))
                currentSoundEffect?.play()
            } catch {
            }
        }
    }
}

//struct PlayGameView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlayGameView()
//    }
//}


// (1) https://www.hackingwithswift.com/quick-start/swiftui/how-to-use-a-timer-with-swiftui
