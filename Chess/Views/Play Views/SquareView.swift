//
//  SquareView.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/13/20.
//

import SwiftUI

struct SquareView: View {
    @EnvironmentObject var engineViewModel : EngineViewModel
    @Binding var board : ChessBoard
    @Binding var notation : MoveList
    @Binding var isGameOver : Bool
    @Binding var selectedSquare : [Int?]
    @Binding var storedPawnPromotionMove : Move?
    @Binding var allMoves : MoveList
    
    var possibleMove : Move?
    
    let rank : Int
    let file : Int
    let shade : Color
    let size : CGFloat
    
    let playSound: (String?) -> Void
    
    var currentSide : Side { engineViewModel.currentSideByNotation(notation: notation) }
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .fill(shade)
                .frame(width: size, height: size)
            
            Circle()
                .fill(Constants.highlightShade)
                .frame(width: size * CGFloat(Constants.highlightCircleFactorReduction),
                       height: size * CGFloat(Constants.highlightCircleFactorReduction))
                .opacity((possibleMove != nil) && (storedPawnPromotionMove == nil) ? 0.3 : 0.0)
            
            // size was 33
            ScaledTextView(content: board[rank][file].rawValue,
                           width: size,
                           height: size)
            
            // Deals with pawn promotions
            if let pawnPromotionMove = storedPawnPromotionMove {
                if pawnPromotionMove.rank == rank &&
                    pawnPromotionMove.file == file {
                    Menu(content: {
                        ForEach(pawnPromotionPieces(currentSide: currentSide), id: \.self) { pawnPromotionPiece in
                            Button("\(pawnPromotionPiece.rawValue)") {
                                if var chosenMove = storedPawnPromotionMove {
                                    chosenMove.piecePromotedTo = pawnPromotionPiece
                                    board[rank][file] = pawnPromotionPiece
                                    if engineViewModel.isMoveCheck(board: board, currentSide: currentSide) {
                                        chosenMove.check = true
                                    }
                                    notation.append(chosenMove)
                                    
                                    allMoves = engineViewModel.allValidMoves(board: board,
                                                                             notation: notation,
                                                                             currentSide: currentSide)
                                    if let finalMove = checkIfFinalMove() {
                                        let _ = notation.popLast()
                                        notation.append(finalMove)
                                        isGameOver = true
                                    }
                                    
                                    storedPawnPromotionMove = nil
                                    
                                }
                            }
                        }
                    }, label: { Label("", systemImage: "star.fill")
                        .labelStyle(IconOnlyLabelStyle())
                    })
                    .accentColor(.clear)
                }
                
            }
        }
        .onTapGesture {
            // Only let moves occur when pieces are not being promoted
            if !isGameOver && storedPawnPromotionMove == nil {
                if let chosenMove = possibleMove {
                    board = engineViewModel.makeMoveSimulation(board: board, move: chosenMove)
                    
                    if chosenMove.pieceCaptured == nil {
                        playSound(engineViewModel.settingsModel.settings.piecePlacementSound)
                    }
                    else {
                        playSound(engineViewModel.settingsModel.settings.pieceCaptureSound)
                    }
                    
                    if engineViewModel.isMovePawnPromotion(move: chosenMove) {
                        storedPawnPromotionMove = chosenMove
                    }
                    
                    else {
                        notation.append(chosenMove)
                        // Refreshes every move possible by all pieces on a given side
                        
                        allMoves = engineViewModel.allValidMoves(board: board,
                                                                 notation: notation,
                                                                 currentSide: currentSide)
                        
                        if let finalMove = checkIfFinalMove() {
                            let _ = notation.popLast()
                            notation.append(finalMove)
                            
                            if finalMove.draw != nil {
                                playSound(engineViewModel.settingsModel.settings.drawSound)
                            }
                            
                            else {
                                playSound(engineViewModel.settingsModel.settings.checkmateSound)
                            }
                            
                            isGameOver = true
                            
                        }
                    }
                    
                }
                else {
                    selectedSquare = [rank, file]
                }
            }
        }
    }
    // Shows all pieces a pawn can promote to
    func pawnPromotionPieces(currentSide : Side) -> [ChessPiece] {
        if currentSide == .white {
            return [.knightWhite, .bishopWhite, .rookWhite, .queenWhite]
        }
        else {
            return [.knightBlack, .bishopBlack, .rookBlack, .queenBlack]
        }
    }
    
    func checkIfFinalMove() -> Move? {
        let noMovesLeft = allMoves.isEmpty
        let insufficentMaterial = engineViewModel.isInsufficentMaterial(board: board)
        let drawnByRepetition = engineViewModel.isDrawByRepetition(board: board, notation: notation)
        
        if noMovesLeft || insufficentMaterial || drawnByRepetition {
            
            var finalMove = notation.last!
            
            // Checks for Checkmate or Statemate
            if noMovesLeft {
                if finalMove.check == true {
                    finalMove.check = false
                    finalMove.checkmate = true
                }
                else {
                    finalMove.draw = .stalemate
                }
            }
            // Checks for insufficent material draw
            else if insufficentMaterial {
                finalMove.draw = .insufficientMaterial
            }
            // Checks for 3 fold repetition draw
            else if drawnByRepetition {
                finalMove.draw = .repetition
            }
            return finalMove
            
        }
        return nil
    }
    
}


//struct SquareView_Previews: PreviewProvider {
//    static var previews: some View {
//        SquareView()
//    }
//}
