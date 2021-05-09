//
//  SettingsModel.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/21/20.
//

// Sounds from ZapSplat.com

import Foundation

struct SettingsModel {
    
    static let defaultSettings = ChessSettings(currentBoardTheme: BoardTheme.regal,
                                               piecePlacementSound: "pop",
                                               pieceCaptureSound: "swords",
                                               checkmateSound: "champion",
                                               drawSound: "finale",
                                               showMenuToolTip: true,
                                               showGameSetupToolTip: true,
                                               showPlayGameToolTip: true,
                                               showGameReviewToolTip: true,
                                               showGameIndividualToolTip: true,
                                               showPreferencesToolTip: true)
    
    var settings : ChessSettings
    private let destinationURL : URL
    
    // light tile and dark tile will be here as computed properties (dictionary from the constant file)
    
    init() {
        let filename = "ChessSettingsData"
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
            settings = try decoder.decode(ChessSettings.self, from: data)
            
        } catch  {
            print("Error info: \(error)")
            settings = SettingsModel.defaultSettings
        }
    }
    
    func saveData() {
        let encoder = JSONEncoder()
        do {
            let data  = try encoder.encode(settings)
            try data.write(to: self.destinationURL)
        } catch  {
            print("Error writing: \(error)")
        }
    }
    
}

// Adapted from Dr. Hannan's "US States" app
