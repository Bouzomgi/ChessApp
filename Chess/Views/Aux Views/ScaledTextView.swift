//
//  ScaledTextView.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/19/20.
//

import SwiftUI

struct ScaledTextView: View {
    var content : String
    var width : CGFloat? = nil
    var height : CGFloat? = nil
    var alignment: Alignment = .center
    var fontName: String? = ""
    var body: some View {
        
        if height != nil && width != nil {
            Text("\(content)")
                .frame(width: width!, height: height!, alignment: alignment)
                .font(Font.custom(fontName ?? "", size: Constants.arbitraryLargeFontSize))
                .minimumScaleFactor(
                    .leastNonzeroMagnitude)
        }
        else if height != nil {
            Text("\(content)")
                .frame(height: height!, alignment: alignment)
                .font(Font.custom(fontName ?? "", size: Constants.arbitraryLargeFontSize))
                .minimumScaleFactor(
                    .leastNonzeroMagnitude)
        }
        else if width != nil {
            Text("\(content)")
                .frame(width: width!, alignment: alignment)
                .font(Font.custom(fontName ?? "", size: Constants.arbitraryLargeFontSize))
                .minimumScaleFactor(
                    .leastNonzeroMagnitude)
        }
        else {
            EmptyView()
        }
            
   }
}

//struct ScaledTextView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScaledTextView()
//    }
//}
