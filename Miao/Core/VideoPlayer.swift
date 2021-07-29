//
//  VideoPlayer.swift
//  Miao
//
//  Created by tree on 2021/7/16.
//

import Foundation
import AVFoundation

class VideoPlayer {
    
    private let queue: DispatchQueue = DispatchQueue.init(label: UUID().uuidString)
    
    let player: AVQueuePlayer
    
    private var rate: Float = 1.0
        
    public private(set) var currentItem: VideoItem?
    
    private var playList: [VideoItem] = []
    
    private var looper: AVPlayerLooper?
    
    init(player: AVQueuePlayer) {
        self.player = player
    }
    
    public func play(item: VideoItem) {
        currentItem = item
        player.removeAllItems()
        let newItem: AVPlayerItem = item.generatePlayItem()
        looper = nil
        if Config.shared.playMode == .single {
            looper = AVPlayerLooper(player: player, templateItem: newItem)
        }
        player.replaceCurrentItem(with: newItem)
        player.volume = Float(Config.shared.volumn)
        player.seek(to: .zero)
        play()
    }
    // 配置播放列表
    func preparePlayList(_ list: [VideoItem]) {
        guard list.isEmpty == false, let first = list.first, let last = list.last else { return }
        var newList = [last]
        newList += list
        newList.append(first)
        playList = newList
    }
    
    // 暂停
    func pause() {
        player.pause()
    }
    
    // 下一个
    public func advanceToNextItemIfNeeded() {
        guard let item = currentItem else { return }
        guard let newIndex = playList.firstIndex(of: item)?.advanced(by: 1) else { return }
        let newItem = playList[newIndex]
        play(item: newItem)
    }
    
    // 上一个
    public func advanceToPrevItemIfNeeded() {
        guard let item = currentItem else { return }
        guard let newIndex = playList.lastIndex(of: item)?.advanced(by: -1) else { return }
        let newItem = playList[newIndex]
        play(item: newItem)
    }
    
    // 随机一个
    @discardableResult
    public func advancePlayRandomItem(_ except: VideoItem? = nil) -> Bool {
        var newList = playList
        if let exceptItem = except {
            newList.removeAll(where: { $0.uuid == exceptItem.uuid })
        }
        guard let item = newList.randomElement() else { return false }
        play(item: item)
        return true
    }
    
    // 播放
    private func play() {
        player.playImmediately(atRate: rate)
        player.actionAtItemEnd = .none
        player.play()
    }
}
