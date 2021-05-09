//
//  ToolTipView.swift
//  Chess
//
//  Created by Brian Ouzomgi on 12/12/20.
//

import SwiftUI

struct ToolTipView: View {
    @Binding var showToolTip : Bool
    let content : String
    
    var body: some View {
        Button(action: {}) { EmptyView() }
            .alert(isPresented: $showToolTip) { () -> Alert in
                let leaveButton = Alert.Button.default(Text("OK")) {
                    showToolTip = false
                }
                return Alert(title: Text("Welcome to ChessApp!"),
                             message: Text(content),
                             dismissButton: leaveButton)
            }

    }
}

//struct ToolTipView_Previews: PreviewProvider {
//    static var previews: some View {
//        IntroductionPopUpView()
//    }
//}
