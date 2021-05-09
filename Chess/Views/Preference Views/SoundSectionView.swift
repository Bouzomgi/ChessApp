//
//  SoundSectionView.swift
//  Chess
//
//  Created by Brian Ouzomgi on 12/2/20.
//

import SwiftUI

struct SoundSectionView: View {
    @EnvironmentObject var engineViewModel : EngineViewModel
    let headerText : String
    let soundOptions : [String?]
    @Binding var settingSelection : String?
    let playSound: (String?) -> Void
    
    var body: some View {
        Picker(headerText, selection: $settingSelection) {
            ForEach(soundOptions, id: \.self) { soundName in
                PickerButton(content: soundName?.capitalizeFirstLetter() ?? "None")
                .fixedSize()
            }
        }
        .onChange(of: settingSelection) { newValue in
            playSound(settingSelection)
        }
    }
}

//struct SoundSectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        SoundSectionView()
//    }
//}
