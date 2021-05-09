//
//  ChessApp.swift
//  Chess
//
//  Created by Brian Ouzomgi on 10/16/20.
//

import SwiftUI

@main
struct ChessApp: App {
    @Environment(\.scenePhase) private var scenePhase
    let engineViewModel = EngineViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(engineViewModel)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .inactive:
                engineViewModel.engineModel.saveData()
                engineViewModel.settingsModel.saveData()
            default:
                break
            }
        }
    }
}
