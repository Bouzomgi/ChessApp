//
//  MiniBoardView.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/22/20.
//

import SwiftUI

struct MiniBoardView: View {
    @EnvironmentObject var engineViewModel : EngineViewModel
    @State var board : ChessBoard
    @State var notation : MoveList = []
    @State var isGameOver = true
    @State var selectedSquare : [Int?] = [nil, nil]
    @State var storedPawnPromotionMove : Move? = nil
    @State var allMoves : MoveList = []
    @State var currentMoveIndex = -1
    
    var squareSize : CGFloat
    var body: some View {
        
        VStack(spacing: 0) {
            ForEach(0..<2, id: \.self) { squareRank in
                HStack(spacing: 0) {
                    ForEach(0..<2, id: \.self) { squareFile in
                        
                        SquareView(board: $board,
                                   notation: $notation,
                                   isGameOver: $isGameOver,
                                   selectedSquare: $selectedSquare,
                                   storedPawnPromotionMove: $storedPawnPromotionMove,
                                   allMoves: $allMoves,
                                   rank: squareRank,
                                   file: squareFile,
                                   shade: squareColor(yPosition: squareRank, xPosition: squareFile),
                                   size: squareSize,
                                   playSound: {_ in })
                        
                    }
                }
            }
        }
    }
    func squareColor(yPosition: Int, xPosition: Int) -> Color {
        return engineViewModel.isOdd(yPosition + xPosition) ?
            Constants.boardLightTile(settings: engineViewModel.settingsModel.settings) :
            Constants.boardDarkTile(settings: engineViewModel.settingsModel.settings)
    }
}

//struct MiniBoardView_Previews: PreviewProvider {
//    static var previews: some View {
//        MiniBoardView()
//    }
//}
