//
//  VideoManager.swift
//  Miao
//
//  Created by tree on 2021/7/21.
//

import Foundation
import Cocoa
import AVKit
import FileKit

class MediaResourceManager: ObservableObject {
    static var `shared`: MediaResourceManager = MediaResourceManager()
    // 定义的常量
    private struct K {
        static let cacheDir = Path.userMovies + "Miao" + ".cache"
        
        static let activeVideoUUIDsKey = "active.file.uuid"
        
        static let allVideoConfigPath = Path.userMovies + "Miao" + ".config" + "all.videos"
    }
    
    // 可用的window
    private var windows: [ScreenSaverVideoWrapperWindow] = []
    
    // 所有视频列表
    @Published private(set) var resources: [VideoItem] = []
    
    // 当前激活状态的视频列表
    @Published var activeVideos: Set<VideoItem> = Set() {
        willSet {
            let values = Array(newValue).map({ $0.uuid.uuidString })
            UserDefaults.standard.set(values, forKey: K.activeVideoUUIDsKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    // 等同`resources`， 通过这个属性可以对视图更新
    private var allVideos: Set<VideoItem> = Set() {
        willSet {
            resources = Array(newValue)
            guard let data = try? JSONEncoder().encode(resources) else { return }
            try? data.write(to: K.allVideoConfigPath)
        }
    }
    
    private lazy var player = VideoPlayer(player: AVQueuePlayer())
    
    private init() {
        createDirIfNeeded()
        if let data = try? Data(contentsOfPath: K.allVideoConfigPath),
           let values = try? JSONDecoder().decode([VideoItem].self, from: data) {
            values.forEach({ allVideos.insert($0) })
        }
        if let uuids = UserDefaults.standard.array(forKey: K.activeVideoUUIDsKey) as? [String] {
            uuids
                .compactMap({uuidString in
                    allVideos.first(where: {item in item.uuid == UUID(uuidString: uuidString)})
                })
                .forEach({ activeVideos.insert($0) })
        }
        loadItemsIfNeeded()
        setupNotificationIfNeeded()
    }
    
    
    // 插入资源
    @discardableResult
    func  insert(resources: [VideoItem]) -> Bool {
        return resources.reduce(true, { $0 && insert(resource: $1) })
    }
    
    func insert(resource: ResourceType) -> Bool {
        guard let item = resource as? VideoItem,
              let fileName = item.path?.fileName else { return  false }
        
        let newPath = K.cacheDir + fileName
        guard let oldData = try? Data.init(contentsOf: item.url) else {
            return false
        }
        try? oldData.write(to: newPath, options: [])
        
        let newItem = VideoItem(path: newPath)
        allVideos.insert(newItem)
        return true
    }
    
    @discardableResult
    func remove(_ resource: VideoItem) -> Bool {
        allVideos.remove(resource)
        try? resource.path?.deleteFile()
        return true
    }
    
    func removeAll() {
        _ = allVideos.map(remove)
        _ = activeVideos.map(remove)
        resources.removeAll()
    }
    
    // 切换资源的可用状态
    @discardableResult
    func toggelActive(_ item: VideoItem) -> Bool {
        if activeVideos.contains(item) {
            activeVideos.remove(item)
        } else {
            activeVideos.insert(item)
        }
        player.preparePlayList(Array(activeVideos))
        return true
    }
    
    // 资源是否可用
    func isActive(_ item: VideoItem) -> Bool {
        return activeVideos.contains(item)
    }
    
    func reloadWindows() {
        windows.forEach({ $0.close() })
        windows = NSScreen.screens
            .filter({ Config.shared.applyAllScreen ? true : $0 == NSScreen.main })
            .map({ ScreenSaverVideoWrapperWindow(screen: $0) })
        windows.forEach({ $0.setupPlayerLayerIfNeeded(player.player) })
    }
    func launch() {
        reloadWindows()
        player.preparePlayList(Array(activeVideos))
        guard let firstItem = activeVideos.first else { return }
        player.play(item: firstItem)
    }
    // 播放
    func playIfNeeded() {
        
    }
    
    func setupNotificationIfNeeded() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onPlayDidEnd(_:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
    
    @objc func onPlayDidEnd(_ notification: Notification) {
        guard let item = notification.object as? AVPlayerItem,
              let currentItem = player.player.currentItem,
              item == currentItem else { return }
        switch Config.shared.playMode {
        case .loop:
            player.advanceToNextItemIfNeeded()
            break
        case .random:
            player.advancePlayRandomItem()
            break
        case .single: return
        }

    }
}

// MARK: 外界状态变化后调用
extension MediaResourceManager {
    
    func playModeDidChangeTo(_ newMode: PlayMode) {
        switch newMode {
        case .loop, .random:
            activeVideos.removeAll()
            player.preparePlayList(resources)
            guard let item = resources.first else { return }
            player.play(item: item)
            break
        case .single:
            guard let remain = activeVideos.first else { return }
            activeVideos.removeAll()
            toggelActive(remain)
            break
        }
    }
    
    func volumnDidChange(_ newValue: Float) {
        player.player.volume = newValue
        player.player.isMuted = newValue.isZero
    }
}

// MARK: 私有方法
fileprivate extension MediaResourceManager {
    func createDirIfNeeded() {
        for path in [K.cacheDir] {
            if path.exists { continue }
            do {
                try path.createDirectory()
            } catch {
                print("\(path) 创建失败 \(error)")
            }
        }
        for path in [K.allVideoConfigPath] {
            if path.exists { continue }
            do {
                try path.parent.createDirectory()
            }
            catch {
                print("\(path) 创建失败 \(error)")
            }
        }
    }
    
    func loadItemsIfNeeded() {
//        print(K.cacheDir)
//        if !K.cacheDir.exists {
//            try? K.cacheDir.createDirectory()
//        }
//        let items = K.cacheDir.children()
//            .filter({ $0.pathExtension == "mp4" })
//            .map(VideoItem.init)
//        resources = items
    }
    
}
