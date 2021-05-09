//
//  BoardView.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/13/20.
//

import SwiftUI
import AVFoundation

struct BoardView: View {
    @EnvironmentObject var engineViewModel : EngineViewModel
    @Binding var board : ChessBoard
    @Binding var notation : MoveList
    @Binding var isGameOver : Bool
    @Binding var allMoves : MoveList
    
    @State var storedPawnPromotionMove : Move? = nil
    
    // In the order of [previousRank, previousFile], [newRank, newFile]
    @State var selectedSquares : [Int?] = [nil, nil]
    
    let squareSize : CGFloat
    
    let playSound: (String?) -> Void
    
    var currentSide : Side { engineViewModel.currentSideByNotation(notation: notation) }
    
    var body: some View {
        VStack(spacing: 0) {
            
            let rankOrdering = (currentSide == .white ? Array((0..<Constants.squaresLimit).reversed()) : Array(0..<Constants.squaresLimit))
            
            // Every move possible by the selected piece
            let currentPossibleMoves = engineViewModel.possibleMovesGivenStart(board: board,
                                                                               currentSide: currentSide,
                                                                               validMoves: allMoves,
                                                                               startingRank: selectedSquares[0],
                                                                               startingFile: selectedSquares[1])
            
            ForEach(rankOrdering, id: \.self) { rank in
                HStack(spacing: 0) {
                    ForEach(0..<Constants.squaresLimit, id: \.self) { file in
                        
                        // A specific possible move between the selected squares
                        let possibleMove = engineViewModel.moveBySquare(moveList: currentPossibleMoves,
                                                                        currentRank: rank,
                                                                        currentFile: file)
                        
                        SquareView(board: $board,
                                   notation: $notation,
                                   isGameOver: $isGameOver,
                                   selectedSquare : $selectedSquares,
                                   storedPawnPromotionMove : $storedPawnPromotionMove,
                                   allMoves: $allMoves,
                                   possibleMove: possibleMove,
                                   rank: rank,
                                   file: file,
                                   shade:
                                    squareColor(xPosition: rank, yPosition: file),
                                   size: squareSize,
                                   playSound: playSound)
                        
                    }
                }
            }
        }
    }
    func squareColor(xPosition: Int, yPosition: Int) -> Color {
        return engineViewModel.isOdd(xPosition + yPosition) ?
            Constants.boardLightTile(settings: engineViewModel.settingsModel.settings) :
            Constants.boardDarkTile(settings: engineViewModel.settingsModel.settings)
    }
}

//struct BoardView_Previews: PreviewProvider {
//    static var previews: some View {
//        BoardView()
//    }
//}
