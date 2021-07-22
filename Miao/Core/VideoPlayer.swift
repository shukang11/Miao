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
    
    private let player: AVQueuePlayer
    
    private var rate: Float = 1.0
    
    private var currentItem: VideoItem?
    
    private var playList: [VideoItem] = []
    
    private var looper: AVPlayerLooper?
    
    init(player: AVQueuePlayer) {
        self.player = player
        setupNotificationIfNeeded()
    }
    
    func play(item: VideoItem) {
        removeObserverIfNeeded()
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
    
    func preparePlayList(_ list: [VideoItem]) {
        guard list.isEmpty == false, let first = list.first, let last = list.last else { return }
        var newList = [last]
        newList += list
        newList.append(first)
        playList = newList
    }
    
    func pause() {
        player.pause()
    }
    
    func advanceToNextItemIfNeeded() {
        guard let item = currentItem else { return }
        guard let newIndex = playList.firstIndex(of: item)?.advanced(by: 1) else { return }
        let newItem = playList[newIndex]
        play(item: newItem)
    }
    
    func advanceToPrevItemIfNeeded() {
        guard let item = currentItem else { return }
        guard let newIndex = playList.lastIndex(of: item)?.advanced(by: -1) else { return }
        let newItem = playList[newIndex]
        play(item: newItem)
    }
    
    private func play() {
        player.playImmediately(atRate: rate)
        player.actionAtItemEnd = .none
        
        player.play()
    }
}

private extension VideoPlayer {
    func removeObserverIfNeeded() {
        guard currentItem != nil,
              let _ = player.currentItem else { return }
        
    }
    
    func setupPlayerObserverIfNeeded() {
        
    }
    
    func setupNotificationIfNeeded() {
        NotificationCenter.default.addObserver(self, selector: #selector(onPlayDidEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc func onPlayDidEnd(_ notification: Notification) {
        guard let item = notification.object as? AVPlayerItem, item == self.player.currentItem else { return }
        switch Config.shared.playMode {
        case .loop:
            advanceToNextItemIfNeeded()
            break
        case .random:
            if let nextItem = playList.randomElement() {
                play(item: nextItem)
            }
            break
        case .single: return
        }
        
    }
}
