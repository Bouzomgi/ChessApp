//
//  Constants.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/13/20.
//

import Foundation
import SwiftUI

struct Constants {
    static let themeToLightTile : [BoardTheme : Color] = [.regal : .regalLightTile,
                                                          .ocean : .oceanLightTile,
                                                          .meadow : .meadowLightTile,
                                                          .space : .spaceLightTile]
    
    static let themeToDarkTile : [BoardTheme : Color] = [.regal : .regalDarkTile,
                                                         .ocean : .oceanDarkTile,
                                                         .meadow : .meadowDarkTile,
                                                         .space : .spaceDarkTile]
    
    static let squaresLimit = 8
    
    // Percent size of the highlighted circle in comparison to its respective square
    static let highlightCircleFactorReduction = 0.7
    static let highlightShade = Color.green
    
    static let modeButtonInnerTextSizeRatio : CGFloat = 0.7
    
    static let arbitraryLargeFontSize : CGFloat = 200
    
    static let titleFontSize : CGFloat = 40
    static let menuButtonWidthScaler : CGFloat = 0.85
    static let menuButtonHeightScaler : CGFloat = 0.4
    
    static let preferenceBoardTileScaler : CGFloat = 2.05
    
    static let playGameCurrentPlayerTextScaler : CGFloat = 0.6
    
    static let fileXOffsetScaler : CGFloat = (1/15)
    static let fileYOffsetScaler : CGFloat = 3.8
    static let rankXOffsetScaler : CGFloat = 3.8
    static let rankYOffsetScaler : CGFloat = 0.35
    
    static let allGameDefaultTextHeightScaler : CGFloat = 0.05
    static let allGameDefaultTextWidthScaler : CGFloat = 0.8
    
    static let gameReviewPlayersTextScaler : CGFloat = 0.7
    static let gameReviewWinnerTextScaler : CGFloat = 0.6
    
    static func boardLightTile(settings : ChessSettings) -> Color { themeToLightTile[settings.currentBoardTheme]! }
    static func boardDarkTile(settings : ChessSettings) -> Color { themeToDarkTile[settings.currentBoardTheme]! }
    
}
