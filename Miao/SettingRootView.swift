//
//  PreferenceView.swift
//  Miao
//
//  Created by tree on 2021/7/19.
//

import SwiftUI

private enum Column: Int {
    case video
    case setting
}

struct SettingRootView: View {
    @State private var slectionIndex: Int = Column.video.rawValue
    
    @State var config: Config = Config.shared
    
    var body: some View {
        
        TabView(selection: $slectionIndex,
                content:  {
                    VideoBoardView(manager: .shared).tabItem { Text("视频") }.tag(Column.video.rawValue)
                    PreferenceSettingView().tabItem { Text("设置") }.tag(Column.setting.rawValue)
                }).environmentObject(config)
    }
}

struct PreferenceView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingRootView()
        }
    }
}
