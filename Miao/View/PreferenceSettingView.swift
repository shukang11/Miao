//
//  PreferenceSettingView.swift
//  Miao
//
//  Created by tree on 2021/7/20.
//

import SwiftUI

struct PreferenceSettingView: View {
        
    @EnvironmentObject var config: Config
    
    private let playModeOptions: [PlayMode] = [.loop, .random, .single]
    
    @State var isMute: Bool = true
    
    var body: some View {
        Form {
            Picker("播放模式", selection: $config.playModeValue) {
                ForEach(0 ..< playModeOptions.count) {
                    Text(playModeOptions[$0].description).tag($0)
                }
            }
            
            Toggle("静音", isOn: $isMute)
        }
    }
}

struct PreferenceSettingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreferenceSettingView()
        }
    }
}
