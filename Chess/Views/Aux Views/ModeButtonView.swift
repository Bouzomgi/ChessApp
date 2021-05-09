//
//  ModeButtonView.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/16/20.
//

import SwiftUI

struct ModeButtonView: View {
    var text : String
    var width : CGFloat
    var height : CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20,
                             style: .continuous)
                .fill(Color.gray)
            
            ScaledTextView(content: text,
                           width: width * Constants.modeButtonInnerTextSizeRatio,
                           height: height * Constants.modeButtonInnerTextSizeRatio)
            
        }
        .frame(width: width, height: height)
        
    }
}

//struct ModeButtonView_Previews: PreviewProvider {
//    static var previews: some View {
//        ModeButtonView()
//    }
//}
