//
//  EngineModel.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/13/20.
//

import Foundation

enum Side { case white, black}

typealias ChessBoard = [[ChessPiece]]
typealias MoveList = [Move]
typealias AllGames = [Game]

struct EngineModel {
    
    var allGames : AllGames
    private let destinationURL : URL
    
    init() {
        let filename = "ChessGameData"
        let mainBundle = Bundle.main
        let bundleURL = mainBundle.url(forResource: filename, withExtension: "json")!
        
        let fileManager = FileManager.default
        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        destinationURL = documentURL.appendingPathComponent(filename + ".json")
        let fileExists = fileManager.fileExists(atPath: destinationURL.path)
        
        do {
            let url = fileExists ? destinationURL : bundleURL
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            allGames = try decoder.decode(AllGames.self, from: data)
            
        } catch  {
            print("Error info: \(error)")
            allGames = []
        }
    }
    
    func dateTitles() -> [Int] {
        let titles = Set(allGames.map { $0.datePlayed.hash })
        return titles.sorted()
    }
    
    func dateIndices(filterDateHash: Int) -> [Int] {
        var filteredGames = allGames.filter({ $0.datePlayed.hash == filterDateHash })
        filteredGames.sort { $0.datePlayed.compare($1.datePlayed) == .orderedDescending } //(1)
        let indices = filteredGames.map {game in allGames.firstIndex(where: {$0.id == game.id})!}
        return indices
    }
    
    func dateHashText(dateHash: Int) -> String {
        let day = dateHash % 100
        let month = (dateHash / 100) % 100
        
        return "\(month)/\(day)"
    }
    
    func saveData() {
        let encoder = JSONEncoder()
        do {
            let data  = try encoder.encode(allGames)
            try data.write(to: self.destinationURL)
        } catch  {
            print("Error writing: \(error)")
        }
    }
    
}

// Adapted from Dr. Hannan's "US States" app

// Taken from https://www.agnosticdev.com/content/how-sort-objects-date-swift
