//
//  PreferencesView.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/21/20.
//

import SwiftUI
import AVFoundation

struct PreferencesView: View {
    @EnvironmentObject var engineViewModel : EngineViewModel
    @Binding var isAwayFromMenu : Bool
    
    let placementSounds : [String?] = [nil, "pop", "rattle", "plunk"]
    let captureSounds : [String?] = [nil, "swords", "bomb", "pog"]
    let checkmateSounds : [String?] = [nil, "champion", "fanfare"]
    let drawSounds : [String?] = [nil, "finale", "robot"]
    
    let toolTipContent = """

This is the Customization screen.

Here, you can modify any of the colors and sound effects of your chessboard.
"""
    
    @State var currentSoundEffect: AVAudioPlayer? = nil
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let squareSize = geometry.size.width / 6
            
            VStack {
                
                ZStack {
                    Rectangle()
                        .frame(width: squareSize * Constants.preferenceBoardTileScaler, height: squareSize * Constants.preferenceBoardTileScaler)
                        .foregroundColor(.black)
                    
                    MiniBoardView(board: EngineViewModel.boardPreview,
                                  squareSize: squareSize)
                }
                .padding()
                
                Form {
                    Section(header: Text("Themes")) {
                        Picker("Board Theme", selection: $engineViewModel.settingsModel.settings.currentBoardTheme) {
                            ForEach(BoardTheme.allCases, id: \.self) { theme in
                                PickerButton(content: theme.rawValue)
                                    .fixedSize()
                            }
                        }
                    }
                    
                    Section(header: Text("Sounds")) {
                        SoundSectionView(headerText: "Piece Placement Sound",
                                         soundOptions: placementSounds,
                                         settingSelection: $engineViewModel.settingsModel.settings.piecePlacementSound,
                                         playSound: { _ in playSound(soundLocation: engineViewModel.settingsModel.settings.piecePlacementSound) }
                        )
                        
                        SoundSectionView(headerText: "Piece Capture Sound",
                                         soundOptions: captureSounds,
                                         settingSelection: $engineViewModel.settingsModel.settings.pieceCaptureSound,
                                         playSound: { _ in playSound(soundLocation: engineViewModel.settingsModel.settings.pieceCaptureSound) }
                        )
                        
                        SoundSectionView(headerText: "Checkmate Sound",
                                         soundOptions: checkmateSounds,
                                         settingSelection: $engineViewModel.settingsModel.settings.checkmateSound,
                                         playSound: { _ in playSound(soundLocation: engineViewModel.settingsModel.settings.checkmateSound) }
                        )
                        
                        SoundSectionView(headerText: "Draw Sound",
                                         soundOptions: drawSounds,
                                         settingSelection: $engineViewModel.settingsModel.settings.drawSound,
                                         playSound: { _ in playSound(soundLocation: engineViewModel.settingsModel.settings.drawSound) }
                        )
                        
                    }
                }
                ToolTipView(showToolTip: $engineViewModel.settingsModel.settings.showPreferencesToolTip,
                            content: toolTipContent)
                
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle(Text("Customization"), displayMode: .inline)
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isAwayFromMenu = false
                    }) {
                        Text("Menu")
                            .font(.largeTitle)
                    }
                }
            }
            
        }
    }
    
    func playSound(soundLocation: String?) {
        if let soundFilename = soundLocation {
            let path = Bundle.main.path(forResource: soundFilename, ofType:"mp3")
            
            do {
                currentSoundEffect = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path!))
                currentSoundEffect?.play()
            } catch {
            }
        }
    }
}



//struct PreferencesView_Previews: PreviewProvider {
//    static var previews: some View {
//        PreferencesView()
//    }
//}
