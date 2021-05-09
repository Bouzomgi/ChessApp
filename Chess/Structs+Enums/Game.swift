//
//  Game.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/19/20.
//

import Foundation

struct Game : Codable, Identifiable {
    let id : UUID
    let player1 : String
    let player2 : String
    let datePlayed : Date
    let timeLimit : Int?
    let timeRemainingPlayer1 : Int?
    let timeRemainingPlayer2 : Int?
    let notation : MoveList
}
