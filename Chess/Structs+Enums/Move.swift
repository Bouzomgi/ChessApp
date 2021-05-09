//
//  Move.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/18/20.
//

import Foundation

struct Move : Hashable, Codable {
    let previousRank : Int
    let previousFile : Int
    
    let rank : Int
    let file : Int
    
    let piece : ChessPiece
    
    var ambiguous : Bool = false
    
    var pieceCaptured : ChessPiece? = nil
    var piecePromotedTo : ChessPiece? = nil
    var check : Bool = false
    var checkmate : Bool = false
    var draw : Draw? = nil
    
    var toNotationText : String {
        var notation : String = ""
        
        if [.kingWhite, .kingBlack].contains(piece) {
            // Castling
            if (previousFile == 4 && file == 6) {
                return "O-O"
            }
            // Queenside castling
            else if (previousFile == 4 && file == 2) {
                return "O-O-O"
            }
            
            notation += "K"
        }
        
        else {
            notation += EngineViewModel.notationPrefix[piece]!
        }
        
        if ambiguous && ![.pawnWhite, .pawnBlack].contains(piece) {
            notation += "\(EngineViewModel.fileTitle[previousFile]!)\(previousRank + 1)"
        }
        
        if pieceCaptured != nil {
            if [.pawnWhite, .pawnBlack].contains(piece) {
                notation += "\(EngineViewModel.fileTitle[previousFile]!)"
            }
            notation += "x"
        }
        
        notation += "\(EngineViewModel.fileTitle[file]!)\(rank + 1)"
        
        if let transformedPiece = piecePromotedTo {
            notation += "=\(EngineViewModel.notationPrefix[transformedPiece]!)"
        }
        
        if check {
            notation += "+"
        }
        
        else if checkmate {
            notation += "#"
        }
        
        return notation
    }
    
}
