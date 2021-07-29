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
    
    var body: some View {
        Form {
            Picker("播放模式", selection: $config.playModeValue) {
                ForEach(0 ..< playModeOptions.count) {
                    Text(playModeOptions[$0].description).tag($0)
                }
            }
            
            HStack {
                Slider(value: $config.volumn, in: 0...100) {
                    Text("音量")
                }.disabled(config.isMute)
                Toggle("静音", isOn: $config.isMute)
            }
            
            HStack {
                Spacer()
                Toggle("应用所有屏幕（重启后生效）", isOn: $config.applyAllScreen)
            }
        }
        .padding(20.0)
    }
}

struct PreferenceSettingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreferenceSettingView()
        }
    }
}
