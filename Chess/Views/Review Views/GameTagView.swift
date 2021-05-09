//
//  GameTagView.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/20/20.
//

import SwiftUI

struct GameTagView: View {
    @EnvironmentObject var engineViewModel : EngineViewModel
    var game : Game
    var body: some View {
        // Need touse scaled text view here!!!
        HStack {
            Text("\(game.player1) vs \(game.player2)")
            Spacer()
            Text(engineViewModel.scoreText(game: game))
            Spacer()
            Text(datetimeText(game: game))
        }
    }
    
    func datetimeText(game: Game) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: game.datePlayed)
    }
    
}

//struct GameTagView_Previews: PreviewProvider {
//    static var previews: some View {
//        GameTagView()
//    }
//}
