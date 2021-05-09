//
//  GameReviewView.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/20/20.
//

import SwiftUI
import AVFoundation

struct GameReviewView: View {
    @EnvironmentObject var engineViewModel : EngineViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var board : ChessBoard
    @State var notation : MoveList = []
    @State var isGameOver = false
    @State var allMoves : MoveList = []
    @State var currentMoveIndex = -1
    @State var showInfo = false
    @State var currentSoundEffect: AVAudioPlayer? = nil
    
    let currentSide = Side.white
    
    let toolTipContent = """

This is the individual game review tool.

Tap the forward and backwards arrows to progress the game state in that respective direction by one move.

Holding the arrow will immediately shift the game state to its starting or ending position.

The information icon in the top right of the screen will showcase additional data about the match.
"""
    
    var currentGame : Game
    var body: some View {
        
        GeometryReader { geometry in // necessary to do this here or VStack will get messed up
            
            let squareSize = geometry.size.width / CGFloat(Constants.squaresLimit)
            ScrollViewReader { scrollView in
                
                VStack(spacing: 0) {
                    
                    Group {
                        ScaledTextView(content: "\(currentGame.player1) vs \(currentGame.player2)",
                                       height: squareSize * Constants.gameReviewPlayersTextScaler)
                        
                        ScaledTextView(content: engineViewModel.scoreText(game: currentGame),
                                       height: squareSize * Constants.gameReviewWinnerTextScaler)
                    }
                    .padding(6)
                    
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
                    
                    HStack(spacing: squareSize * 0.8) {
                        Spacer()
                        ScaledTextView(content: "⇦",
                                       height: squareSize * 1.8)
                            
                            .onTapGesture {
                                if currentMoveIndex > -1 {
                                    shortTapBackward()
                                    scrollView.scrollTo(currentMoveIndex, anchor: .center)
                                }
                            }
                            
                            .onLongPressGesture {
                                longTapBackward()
                                scrollView.scrollTo(0, anchor: .center)
                            }
                        
                        ScaledTextView(content: "⇨",
                                       height: squareSize * 1.8)
                            
                            .onTapGesture {
                                if currentMoveIndex < (currentGame.notation.count - 1) {
                                    shortTapForward()
                                    scrollView.scrollTo(currentMoveIndex, anchor: .center)
                                }
                            }
                            
                            .onLongPressGesture {
                                longTapForward()
                                scrollView.scrollTo(currentMoveIndex, anchor: .center)
                            }
                        
                        Spacer()
                    }
                    //                Spacer()
                    Divider()
                    Spacer()
                    
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(0..<currentGame.notation.count, id: \.self) { i in
                                Text(currentGame.notation[i].toNotationText)
                                    .foregroundColor(i == currentMoveIndex ? .red : .black)
                            }
                        }.padding()
                    }
                    .disabled(true)
                    
                }
            }
            
        }
        
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss() //(1)
                }) {
                    Text("Games")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showInfo = true
                }) {
                    Image(systemName: "info.circle")
                }
                
            }
        }
        .alert(isPresented: $showInfo) { () -> Alert in
            let dismissButton = Alert.Button.default(Text("OK")) {}
            return Alert(title: Text("Game Specifics"),
                         message: Text(specificsText()),
                         dismissButton: dismissButton)
        }
        
        ToolTipView(showToolTip: $engineViewModel.settingsModel.settings.showGameIndividualToolTip,
                    content: toolTipContent)
    }
    
    func specificsText() -> String {
        var content = """
White: \(currentGame.player1)
Black: \(currentGame.player2)
Game Score: \(engineViewModel.scoreText(game: currentGame))
\(engineViewModel.scoreText(game: currentGame, abbreviated: false))
Time Limit: \(engineViewModel.timeControlText(time: currentGame.timeLimit))
"""
        if currentGame.timeLimit != nil {
            content += """
                \nWhite's Remaining Time: \(engineViewModel.timeControlText(time:  currentGame.timeRemainingPlayer1!))
                Black's Remaining Time: \(engineViewModel.timeControlText(time: currentGame.timeRemainingPlayer2!))
                """
        }
        
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MM-dd-YYYY"
        timeFormatter.dateFormat = "HH:mm"
        
        let dateString = dateFormatter.string(from: currentGame.datePlayed)
        let timeString = timeFormatter.string(from: currentGame.datePlayed)
        
        content += "\n\nGame was played on \(dateString) starting at \(timeString)"
        
        return content
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
    
    func shortTapBackward() {
        board = engineViewModel.makeMoveSimulation(board: board,
                                                   move: currentGame.notation[currentMoveIndex],
                                                   backwards: true)
        
        if currentGame.notation[currentMoveIndex].pieceCaptured == nil {
            playSound(soundLocation: engineViewModel.settingsModel.settings.piecePlacementSound)
        }
        else {
            playSound(soundLocation: engineViewModel.settingsModel.settings.pieceCaptureSound)
        }
        
        currentMoveIndex -= 1
    }
    
    
    func longTapBackward() {
        board = EngineViewModel.boardStartingPosition
        currentMoveIndex = -1
    }
    
    
    func shortTapForward() {
        currentMoveIndex += 1
        board = engineViewModel.makeMoveSimulation(board: board,
                                                   move: currentGame.notation[currentMoveIndex])
        
        if currentGame.notation[currentMoveIndex].pieceCaptured == nil {
            playSound(soundLocation: engineViewModel.settingsModel.settings.piecePlacementSound)
        }
        else {
            playSound(soundLocation: engineViewModel.settingsModel.settings.pieceCaptureSound)
        }
        
        print(engineViewModel.settingsModel.settings.showGameIndividualToolTip)
    }
    
    func longTapForward() {
        while currentMoveIndex < (currentGame.notation.count - 1) {
            currentMoveIndex += 1
            board = engineViewModel.makeMoveSimulation(board: board,
                                                       move: currentGame.notation[currentMoveIndex])
        }
    }
}
//struct IndividualGameReviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        IndividualGameReviewView()
//    }
//}

// https://stackoverflow.com/questions/56571349/custom-back-button-for-navigationviews-navigation-bar-in-swiftui
