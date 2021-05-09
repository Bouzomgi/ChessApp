//
//  ChessPiece.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/18/20.
//

import Foundation

enum ChessPiece : String, Codable {
    case pawnWhite = "\u{2659}",
         knightWhite = "\u{2658}",
         bishopWhite = "\u{2657}",
         rookWhite = "\u{2656}",
         queenWhite = "\u{2655}",
         kingWhite = "\u{2654}",
         
         pawnBlack = "\u{265F}\u{0000FE0E}",
         knightBlack = "\u{265E}",
         bishopBlack = "\u{265D}",
         rookBlack = "\u{265C}",
         queenBlack = "\u{265B}",
         kingBlack = "\u{265A}",
         
         empty = ""
}
