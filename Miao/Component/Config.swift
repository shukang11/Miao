//
//  Config.swift
//  Miao
//
//  Created by tree on 2021/7/20.
//

import Foundation
import SwiftUI
import FileKit

enum PlayMode: Int {
    case loop
    case random
    case single
}

extension PlayMode: CustomStringConvertible {
    var description: String {
        switch self {
        case .loop:
            return "列表循环"
        case .random:
            return "随机播放"
        case .single:
            return "指定资源"
        }
    }
}

class Config: ObservableObject {
    // 播放模式
    @AppStorage("play.mode.value") var playModeValue: Int = PlayMode.loop.rawValue {
        willSet {
            MediaResourceManager.shared.playModeDidChangeTo(playMode)
        }
    }
    // 默认🙅🏻‍♀️拷贝资源
    @AppStorage("copy.if.needed") var copyIfNeeded: Bool = false
    // 视频最终的存储目录
    @AppStorage("path.release") var releasePath: String = Path.userMovies.standardRawValue
    // 播放音量
    @AppStorage("play.volumn") var volumn: Int = 0
    // 是否是静音播放
    @AppStorage("play.mute") var isMute: Bool = true
    
    var playMode: PlayMode {
        return PlayMode(rawValue: playModeValue) ?? .loop
    }
    
    static var `shared`: Config = Config()
    
    private init() {}
}
