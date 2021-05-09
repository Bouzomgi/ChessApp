//
//  EngineViewModel.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/18/20.
//

import Foundation

class EngineViewModel : ObservableObject {
    
    @Published var engineModel = EngineModel()
    @Published var settingsModel = SettingsModel()
    
    static let fileTitle = [0: "a", 1: "b", 2: "c", 3: "d", 4: "e", 5: "f", 6:"g", 7: "h"]
    
    static let pieceColor : [ChessPiece : Side] = [.pawnWhite : .white,
                                                   .knightWhite : .white,
                                                   .bishopWhite : .white,
                                                   .rookWhite : .white,
                                                   .queenWhite : .white,
                                                   .kingWhite : .white,
                                                   
                                                   .pawnBlack : .black,
                                                   .knightBlack : .black,
                                                   .bishopBlack : .black,
                                                   .rookBlack : .black,
                                                   .queenBlack : .black,
                                                   .kingBlack : .black]
    
    static let notationPrefix : [ChessPiece : String] = [.pawnWhite : "",
                                                         .knightWhite : "N",
                                                         .bishopWhite : "B",
                                                         .rookWhite : "R",
                                                         .queenWhite : "Q",
                                                         .kingWhite : "K",
                                                         
                                                         .pawnBlack : "",
                                                         .knightBlack : "N",
                                                         .bishopBlack : "B",
                                                         .rookBlack : "R",
                                                         .queenBlack : "Q",
                                                         .kingBlack : "K"]
    
    static let boardStartingPosition : ChessBoard =
        [[.rookWhite, .knightWhite, .bishopWhite, .queenWhite, .kingWhite, .bishopWhite, .knightWhite, .rookWhite],
         Array(repeating: .pawnWhite, count: 8),
         Array(repeating: .empty, count: 8),
         Array(repeating: .empty, count: 8),
         Array(repeating: .empty, count: 8),
         Array(repeating: .empty, count: 8),
         Array(repeating: .pawnBlack, count: 8),
         [.rookBlack, .knightBlack, .bishopBlack, .queenBlack, .kingBlack, .bishopBlack, .knightBlack, .rookBlack]]
    
    static let boardPreview : ChessBoard =
        [[.empty, .pawnBlack],
         [.pawnWhite, .empty]]
    
    
    func areOppositeColors(pieceColor1: Side?, pieceColor2: Side?) -> Bool {
        if pieceColor1 != nil && pieceColor2 != nil {
            return (pieceColor1! == .white && pieceColor2! == .black) || (pieceColor1! == .black && pieceColor2! == .white)
        }
        // If either squares are empty
        else {
            return false
        }
    }
    
    func isInBounds(rank: Int, file: Int) -> Bool {
        let validSquares = 0..<8
        return validSquares.contains(rank) && validSquares.contains(file)
    }
    
    func hasPieceMoved(notation: MoveList, rank: Int, file: Int) -> Bool {
        for move in notation {
            if move.previousRank == rank && move.previousFile == file {
                return true
            }
        }
        return false
    }
    
    func findOppositeSide(currentSide : Side) -> Side { currentSide == .white ? .black : .white }
    
    func movesToNotation(moves: MoveList) -> String {
        let distinctNotation = moves.map { $0.toNotationText }
        return distinctNotation.joined(separator: " ")
    }
    
    // Used for the bishop, rook, and queen (straight path pieces)
    // Gives list of all valid moves for above pieces (ignoring check)
    func movesByDirection(board: ChessBoard, direction: [Int], rank: Int, file: Int, alternativePiece: ChessPiece? = nil) -> MoveList {
        
        let piece : ChessPiece
        
        // For simplifying the computation of the queen's movement (as a combination of a psuedo-bishop & pseudo-rook at the queen's location)
        piece = alternativePiece ?? board[rank][file]
        
        let currentSide = EngineViewModel.pieceColor[piece]
        
        var moveList : MoveList = []
        
        var newRank = rank + direction[1]
        var newFile = file + direction[0]
        
        while isInBounds(rank: newRank, file: newFile) {
            let squareTravelingTo = board[newRank][newFile]
            
            if EngineViewModel.pieceColor[squareTravelingTo] == currentSide {
                return moveList
            }
            
            else {
                var newMove = Move(previousRank: rank,
                                   previousFile: file,
                                   rank: newRank,
                                   file: newFile,
                                   piece: piece)
                
                if squareTravelingTo == .empty {
                    moveList.append(newMove)
                }
                
                else if areOppositeColors(pieceColor1:
                                            EngineViewModel.pieceColor[squareTravelingTo],
                                          pieceColor2:
                                            currentSide) {
                    newMove.pieceCaptured = squareTravelingTo
                    moveList.append(newMove)
                    return moveList
                }
                
            }
            newRank += direction[1]
            newFile += direction[0]
            
        }
        
        return moveList
    }
    
    func computeMoves(board: ChessBoard, notation: MoveList = [], rank: Int, file: Int, alternativePiece: ChessPiece? = nil) -> MoveList {
        
        let piece : ChessPiece
        
        // For simplifying the computation of the queen's movement (as a combination of a psuedo-bishop & pseudo-rook at the queen's location)
        piece = alternativePiece ?? board[rank][file]
        
        let currentSide = EngineViewModel.pieceColor[piece]
        
        var moveList : MoveList = []
        var newMove : Move
        var newFile : Int
        var newRank : Int
        var directionVectors : [Int]
        
        // PAWNS
        if [.pawnWhite, .pawnBlack].contains(piece) {
            //White pieces move upward, black pieces move downward
            let directionFileMultiplier = (currentSide == .white ? 1 : -1)
            
            newFile = file
            directionVectors = [1]
            
            // Add double move at start
            if (currentSide == .white && rank == 1) || (currentSide == .black && rank == 6) {
                directionVectors.append(2)
            }
            
            // Moving straight
            for j in directionVectors {
                newRank = rank + (j * directionFileMultiplier)
                
                if isInBounds(rank : newRank, file : newFile) {
                    let squareTravelingTo = board[newRank][newFile]
                    
                    // A piece is blocking the way. The pawn cannot move.
                    if squareTravelingTo != .empty {
                        break
                    }
                    
                    else {
                        newMove = Move(previousRank: rank,
                                       previousFile: file,
                                       rank: newRank,
                                       file: newFile,
                                       piece: piece)
                        
                        moveList.append(newMove)
                    }
                }
            }
            
            // Capturing
            for i in [-1, 1] {
                newFile = file + i
                newRank = rank + directionFileMultiplier
                
                if isInBounds(rank : newRank, file : newFile) {
                    let squareTravelingTo = board[newRank][newFile]
                    
                    if areOppositeColors(pieceColor1:
                                            EngineViewModel.pieceColor[squareTravelingTo],
                                         pieceColor2:
                                            currentSide) {
                        
                        newMove = Move(previousRank: rank,
                                       previousFile: file,
                                       rank: newRank,
                                       file: newFile,
                                       piece: piece,
                                       pieceCaptured: squareTravelingTo)
                        
                        moveList.append(newMove)
                        
                    }
                }
            }
        }
        
        // KNIGHTS
        else if [.knightWhite, .knightBlack].contains(piece) {
            
            for i in [-2, -1, 1, 2] {
                for j in [-2, -1, 1, 2] {
                    if abs(i) != abs(j) {
                        newFile = file + i
                        newRank = rank + j
                        
                        if isInBounds(rank : newRank, file : newFile) {
                            let squareTravelingTo = board[newRank][newFile]
                            
                            if EngineViewModel.pieceColor[squareTravelingTo] == currentSide {
                                continue
                            }
                            
                            var newMove = Move(previousRank: rank,
                                               previousFile: file,
                                               rank: newRank,
                                               file: newFile,
                                               piece: piece)
                            
                            
                            if squareTravelingTo == .empty {
                                moveList.append(newMove)
                            }
                            
                            else if areOppositeColors(pieceColor1:
                                                        EngineViewModel.pieceColor[squareTravelingTo],
                                                      pieceColor2:
                                                        currentSide) {
                                
                                newMove.pieceCaptured = squareTravelingTo
                                moveList.append(newMove)
                            }
                            
                        }
                    }
                }
            }
        }
        
        // BISHOPS
        else if [.bishopWhite, .bishopBlack].contains(piece) {
            for i in [-1, 1] {
                for j in [-1, 1] {
                    
                    moveList += movesByDirection(board: board,
                                                 direction: [i, j],
                                                 rank: rank,
                                                 file: file)
                }
            }
        }
        
        // ROOKS
        else if [.rookWhite, .rookBlack].contains(piece) {
            for i in [-1, 0, 1] {
                for j in [-1, 0, 1] {
                    if abs(i) + abs(j) == 1 {
                        moveList += movesByDirection(board: board,
                                                     direction: [i, j],
                                                     rank: rank,
                                                     file: file)
                    }
                }
            }
        }
        
        // QUEENS
        else if [.queenWhite, .queenBlack].contains(piece) {
            // You can simplify the queen's moves as a combination of both a rook and a bishop
            let tempBishop = (EngineViewModel.pieceColor[piece] == Side.white) ? ChessPiece.bishopWhite : .bishopBlack
            let tempRook = (EngineViewModel.pieceColor[piece] == Side.white) ? ChessPiece.rookWhite : .rookBlack
            
            let bishopMoves = computeMoves(board: board,
                                           rank: rank,
                                           file: file,
                                           alternativePiece: tempBishop)
            
            let rookMoves = computeMoves(board: board,
                                         rank: rank,
                                         file: file,
                                         alternativePiece: tempRook)
            
            moveList = bishopMoves + rookMoves
        }
        
        // KINGS
        else if [.kingWhite, .kingBlack].contains(piece) {
            
            // Castling
            let castlingRank = (EngineViewModel.pieceColor[piece] == Side.white ? 0 : 7)
            
            if board[castlingRank][5] == .empty && board[castlingRank][6] == .empty {
                moveList.append(Move(previousRank: castlingRank,
                                     previousFile: 4,
                                     rank: castlingRank,
                                     file: 6,
                                     piece: piece))
                
            }
            
            // Queenside castling
            if board[castlingRank][1] == .empty && board[castlingRank][2] == .empty && board[castlingRank][3] == .empty {
                moveList.append(Move(previousRank: castlingRank,
                                     previousFile: 4,
                                     rank: castlingRank,
                                     file: 2,
                                     piece: piece))
                
            }
            
            for i in [-1, 0, 1] {
                for j in [-1, 0, 1] {
                    if abs(i) + abs(j) != 0 {
                        newFile = file + i
                        newRank = rank + j
                        
                        if isInBounds(rank : newRank, file : newFile) {
                            let squareTravelingTo = board[newRank][newFile]
                            
                            if EngineViewModel.pieceColor[squareTravelingTo] == currentSide {
                                continue
                            }
                            
                            var newMove = Move(previousRank: rank,
                                               previousFile: file,
                                               rank: newRank,
                                               file: newFile,
                                               piece: piece)
                            
                            if squareTravelingTo == .empty {
                                moveList.append(newMove)
                            }
                            
                            else if areOppositeColors(pieceColor1:
                                                        EngineViewModel.pieceColor[squareTravelingTo],
                                                      pieceColor2:
                                                        currentSide) {
                                newMove.pieceCaptured = squareTravelingTo
                                moveList.append(newMove)
                            }
                            
                        }
                    }
                }
            }
        }
        
        return moveList
    }
    
    // Compute all moves for an input side. May be invalid
    func allMoves(board: ChessBoard, currentSide: Side) -> MoveList {
        var computedMoves : MoveList = []
        
        for rank in 0..<8 {
            for file in 0..<8 {
                if EngineViewModel.pieceColor[board[rank][file]] == currentSide {
                    computedMoves += computeMoves(board: board, rank: rank, file: file)
                }
            }
        }
        return computedMoves
    }
    
    // Returns a sample board after a specific move is made
    func makeMoveSimulation(board: ChessBoard, move: Move, backwards: Bool = false) -> ChessBoard {
        
        // Deep copy the board
        var sampleBoard : ChessBoard = []
        for rank in 0..<Constants.squaresLimit {
            var tempArray : [ChessPiece] = []
            for file in 0..<Constants.squaresLimit {
                tempArray.append(board[rank][file])
            }
            sampleBoard.append(tempArray)
        }
        
        if [.kingWhite, .kingBlack].contains(move.piece) && move.previousFile == 4 {
            
            // Kingside castling
            if move.file == 6 {
                
                if backwards {
                    // Move the Rook
                    let rook = board[move.previousRank][5]
                    sampleBoard[move.previousRank][7] = rook
                    sampleBoard[move.rank][5] = .empty
                }
                else {
                    
                    // Move the Rook
                    let rook = board[move.previousRank][7]
                    sampleBoard[move.previousRank][7] = .empty
                    sampleBoard[move.rank][5] = rook
                }
            }
            
            // Queenside castling
            else if move.file == 2 {
                
                if backwards {
                    // Move the Rook
                    let rook = board[move.previousRank][3]
                    sampleBoard[move.previousRank][0] = rook
                    sampleBoard[move.rank][3] = .empty
                }
                else {
                    
                    // Move the Rook
                    let rook = board[move.previousRank][0]
                    sampleBoard[move.previousRank][0] = .empty
                    sampleBoard[move.rank][3] = rook
                }
            }
        }
        
        // Moving backwards
        if backwards {
            let originalPiece = move.pieceCaptured ?? .empty
            sampleBoard[move.rank][move.file] = originalPiece
            sampleBoard[move.previousRank][move.previousFile] = move.piece
        }
        
        else {
            sampleBoard[move.previousRank][move.previousFile] = .empty
            sampleBoard[move.rank][move.file] = move.piecePromotedTo ?? move.piece
        }
        return sampleBoard
    }
    
    func isKingVurnerable(board: ChessBoard, currentSide: Side) -> Bool {
        let oppositeSide = findOppositeSide(currentSide: currentSide)
        let moves = allMoves(board: board, currentSide: oppositeSide)
        for move in moves {
            if let piece = move.pieceCaptured {
                if piece == (currentSide == .white ? .kingWhite : .kingBlack) {
                    return true
                }
            }
        }
        return false
    }
    
    func isMoveCheck(board: ChessBoard, currentSide: Side) -> Bool {
        
        let oppositeSide = findOppositeSide(currentSide: currentSide)
        if isKingVurnerable(board: board, currentSide: oppositeSide) {
            return true
        }
        return false
    }
    
    // Compute all valid moves for an input side
    func allValidMoves(board: ChessBoard, notation: MoveList, currentSide: Side) -> MoveList {
        var computedMoves : MoveList = allMoves(board: board, currentSide: currentSide)
        
        var moveNotation : String
        var ambiguousNotation : [String : Int] = [:]
        var moveIndicesToRemove : Set<Int> = []
        var sampleBoard : ChessBoard
        
        // Ensures ambiguous notation is marked as such
        for (moveIndex, move) in computedMoves.enumerated() {
            moveNotation = move.toNotationText
            
            sampleBoard = makeMoveSimulation(board: board, move: move)
            
            // Move puts opposite King in danger. Check
            if isMoveCheck(board: sampleBoard, currentSide: currentSide) {
                computedMoves[moveIndex].check = true
            }
            
            // King & Queenside castling validity checks
            if ((move.previousFile == 4 && move.file == 6) ||
                    (move.previousFile == 4 && move.file == 2)) &&
                [.kingWhite, .kingBlack].contains(move.piece) {
                
                // Make sure the King hasn't moved
                if !hasPieceMoved(notation: notation, rank: move.previousRank, file: 4) &&
                    
                    // Kingside castling. Right Rook can't move
                    ((!hasPieceMoved(notation: notation, rank: move.previousRank, file: 7) &&
                        (move.previousFile == 4 && move.file == 6)) ||
                        
                        // Queenside castling. Left Rook can't move
                        (!hasPieceMoved(notation: notation, rank: move.previousRank, file: 0) &&
                            (move.previousFile == 4 && move.file == 2))) {
                    
                    let castlingIteration: (Int, Move) -> Int = { movingFile, move in
                        move.file == 6 ? movingFile + 1 : movingFile - 1 }
                    
                    let castlingCheckConditional: (Int, Move) -> Bool = { movingFile, move in
                        move.file == 6 ? movingFile <= move.file : movingFile >= move.file }
                    
                    // Make sure castling doesn't move through check. Mock the King at each location between castling and watch for check.
                    var movingFile = castlingIteration(move.previousFile, move)
                    
                    while castlingCheckConditional(movingFile, move) {
                        let castleSampleMove = Move(previousRank: move.previousRank,
                                                    previousFile: move.previousFile,
                                                    rank: move.rank,
                                                    file: movingFile,
                                                    piece: move.piece)
                        
                        let castleSampleBoard = makeMoveSimulation(board: board, move: castleSampleMove)
                        
                        if (isKingVurnerable(board: castleSampleBoard, currentSide: currentSide)) {
                            moveIndicesToRemove.insert(moveIndex)
                            break
                        }
                        movingFile = castlingIteration(movingFile, move)
                        
                    }
                }
                
                else {
                    moveIndicesToRemove.insert(moveIndex)
                }
            }
            
            // Move puts players King in danger. Invalid
            else if (isKingVurnerable(board: sampleBoard, currentSide: currentSide)) {
                moveIndicesToRemove.insert(moveIndex)
                continue
            }
            
            if let ambiguousIndex = ambiguousNotation[moveNotation] {
                computedMoves[ambiguousIndex].ambiguous = true
                computedMoves[moveIndex].ambiguous = true
            }
            else {
                ambiguousNotation[moveNotation] = moveIndex
            }
        }
        var legalComputedMoves : MoveList = []
        
        // Computes new list of strictly legal moves
        for i in 0..<computedMoves.count {
            if !moveIndicesToRemove.contains(i) {
                legalComputedMoves.append(computedMoves[i])
            }
        }
        
        return legalComputedMoves
    }
    
    func possibleMovesGivenStart(board: ChessBoard, currentSide: Side, validMoves: MoveList, startingRank: Int?, startingFile: Int?) -> MoveList {
        if (startingRank != nil) && (startingFile != nil) {
            return validMoves.filter { ($0.previousRank == startingRank!) && ($0.previousFile == startingFile!) }
        }
        // Move hasn't been selected yet
        else {
            return []
        }
    }
    
    // Returns the move corresponding with this square
    func moveBySquare(moveList: MoveList, currentRank: Int?, currentFile: Int?) -> Move? {
        if (currentRank != nil) && (currentFile != nil) {
            for move in moveList {
                if (move.rank == currentRank!) && (move.file == currentFile!) {
                    return move
                }
            }
        }
        return nil
    }
    
    // Returns a boolean depending on if pawn promotion is necessary
    func isMovePawnPromotion(move: Move) -> Bool {
        if move.piece == .pawnWhite && move.rank == 7 {
            return true
        }
        else if move.piece == .pawnBlack && move.rank == 0 {
            return true
        }
        return false
    }
    
    func timeControlText(time: Int?) -> String {
        var timeText = ""
        if var timeValue = time {
            
            // Hours
            if timeValue / 3600 > 0 {
                timeText += String(format: "%1d:", timeValue / 3600)
                timeValue = timeValue % 3600
            }
            // Minutes
            timeText += String(format: "%02d:", timeValue / 60)
            timeValue = timeValue % 60
            
            // Seconds
            timeText += String(format: "%02d", timeValue)
            
            return timeText
        }
        return "Untimed"
    }
    
    // If either side has no pieces, or only a knight or a bishop, checkmate is impossible
    func isInsufficentMaterial(board: ChessBoard) -> Bool {
        var whiteHasMinor = false
        var blackHasMinor = false
        for rank in 0..<8 {
            for file in 0..<8 {
                if [.bishopWhite, .knightWhite].contains(board[rank][file]) {
                    if whiteHasMinor {
                        return false
                    }
                    else {
                        whiteHasMinor = true
                    }
                }
                else if [.bishopBlack, .knightBlack].contains(board[rank][file]) {
                    if blackHasMinor {
                        return false
                    }
                    else {
                        blackHasMinor = true
                    }
                }
                else if ![.empty, .kingWhite, .kingBlack].contains(board[rank][file]) {
                    return false
                }
            }
        }
        return true
    }
    
    // If the last three moves are the same, trigger a draw
    func isDrawByRepetition(board: ChessBoard, notation: MoveList) -> Bool {
        if notation.count >= 12 {
            let totalMoves = notation.count
            
            for i in 1...2 {
                if notation[totalMoves - (1 + 4*i)] != notation[totalMoves - 1] ||
                    notation[totalMoves - (2 + 4*i)] != notation[totalMoves - 2] ||
                    notation[totalMoves - (3 + 4*i)] != notation[totalMoves - 3] ||
                    notation[totalMoves - (4 + 4*i)] != notation[totalMoves - 4] {
                    
                    return false
                }
                return true
            }
        }
        return false
    }
    
    
    func isOdd(_ value: Int) -> Bool { (value % 2) != 0 }
    
    func currentSideByNotation(notation: MoveList) -> Side { isOdd(notation.count) ? .black : .white }
    
    func scoreText(game: Game, abbreviated: Bool = true) -> String {
        var scoreValue1 : String = ""
        var scoreValue2 : String = ""
        if game.notation.last!.checkmate == true {
            // If game ends on an odd move, white won
            if isOdd(game.notation.count) {
                scoreValue1 = "1"
                scoreValue2 = "0"
                if !abbreviated {
                    return "White had beaten Black by checkmate"
                }
            }
            else {
                scoreValue1 = "0"
                scoreValue2 = "1"
                if !abbreviated {
                    return "Black had beaten White by checkmate"
                }
            }
        }
        else if let drawRationale = game.notation.last!.draw {
            scoreValue1 = "½"
            scoreValue2 = "½"
            if !abbreviated {
                var explaination = "White and Black had drawn by "
                if drawRationale == .insufficientMaterial {
                    explaination += "insufficient material"
                }
                else if drawRationale == .repetition {
                    explaination += "threefold repetition"
                }
                else if drawRationale == .stalemate {
                    explaination += "stalemate"
                }
                else {
                    explaination += "ERROR"
                }
                return explaination
            }
        }
        
        // Player 2 wins on time
        else if let timeRemaining = game.timeRemainingPlayer1 {
            if timeRemaining == 0 {
                scoreValue1 = "0"
                scoreValue2 = "1"
                if !abbreviated {
                    return "Black had beaten White on time"
                }
            }
        }
        
        // Player 1 wins on time
        if let timeRemaining = game.timeRemainingPlayer2 {
            if timeRemaining == 0 {
                scoreValue1 = "1"
                scoreValue2 = "0"
                if !abbreviated {
                    return "White had beaten Black on time"
                }
            }
        }
        
        return "\(scoreValue1)-\(scoreValue2)"
    }
    
}
