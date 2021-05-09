//
//  FileView.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/14/20.
//

import SwiftUI

struct FileView: View {
    let squareSize : CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<Constants.squaresLimit, id: \.self) { file in
                
                ScaledTextView(content: EngineViewModel.fileTitle[file]!,
                               width: squareSize,
                               height: squareSize / CGFloat(3),
                               alignment: .bottomTrailing)
                    .offset(x: -squareSize * Constants.fileXOffsetScaler,
                            y: squareSize * Constants.fileYOffsetScaler)
                
            }
        }
    }
}

//struct FileView_Previews: PreviewProvider {
//    static var previews: some View {
//        FileView()
//    }
//}
