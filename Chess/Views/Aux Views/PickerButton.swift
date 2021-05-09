//
//  PickerButton.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/16/20.
//

import SwiftUI

struct PickerButton: View {
    let content : String
    let color : Color = .clear
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(color)
                .aspectRatio(1.0, contentMode: .fit)
                .shadow(radius: 20)
            Text(content)
        }
    }
}

//struct PickerButton_Previews: PreviewProvider {
//    static var previews: some View {
//        PickerButton()
//    }
//}
