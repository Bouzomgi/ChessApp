//
//  ChessSettings.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/21/20.
//

import Foundation

struct ChessSettings : Codable {
    var currentBoardTheme : BoardTheme
    var piecePlacementSound : String?
    var pieceCaptureSound : String?
    var checkmateSound : String?
    var drawSound : String?
    
    var showMenuToolTip : Bool
    var showGameSetupToolTip : Bool
    var showPlayGameToolTip : Bool
    var showGameReviewToolTip : Bool
    var showGameIndividualToolTip : Bool
    var showPreferencesToolTip : Bool
}

enum BoardTheme : String, Codable, CaseIterable {
    case regal = "Regal",
         ocean = "Ocean",
         meadow = "Meadow",
         space = "Space"
}
