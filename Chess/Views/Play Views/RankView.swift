//
//  RankView.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/14/20.
//

import SwiftUI

struct RankView: View {
    let currentSide : Side
    let squareSize : CGFloat
    
    var body: some View {
        
        let rankOrdering = (currentSide == .white ? Array((0..<Constants.squaresLimit).reversed()) : Array(0..<Constants.squaresLimit))
        
        VStack(spacing: squareSize / 1.4) {
            ForEach(rankOrdering, id: \.self) { rank in
                
                ScaledTextView(content: "\(rank + 1)",
                               width: squareSize / CGFloat(3.5),
                               height: squareSize / CGFloat(3.5),
                               alignment: .topLeading)
                
            }
            
        }
        .offset(x: -squareSize * Constants.rankXOffsetScaler,
                y: -squareSize * Constants.rankYOffsetScaler)
        
    }
}

//struct RankView_Previews: PreviewProvider {
//    static var previews: some View {
//        RankView()
//    }
//}
