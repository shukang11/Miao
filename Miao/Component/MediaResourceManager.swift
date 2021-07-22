//
//  VideoManager.swift
//  Miao
//
//  Created by tree on 2021/7/21.
//

import Foundation
import Cocoa
import FileKit

class MediaResourceManager: ObservableObject {
    static var `shared`: MediaResourceManager = MediaResourceManager()
    private struct K {
        static let cacheDir = Path.userMovies + "Miao" + ".cache"
        
        static let activeVideoUUIDsKey = "active.file.uuid"
                
        static let allVideoConfigPath = Path.userMovies + "Miao" + ".config" + "all.videos"
    }
    
    private var windows: [ScreenSaverVideoWrapperWindow] = []
    
    @Published private(set) var resources: [VideoItem] = []
    
    @Published var activeVideos: Set<VideoItem> = Set() {
        willSet {
            let values = Array(newValue).map({ $0.uuid.uuidString })
            UserDefaults.standard.set(values, forKey: K.activeVideoUUIDsKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    private var allVideos: Set<VideoItem> = Set() {
        willSet {
            resources = Array(newValue)
            guard let data = try? JSONEncoder().encode(resources) else { return }
            try? data.write(to: K.allVideoConfigPath)
        }
    }
    
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
    }
    
    
    /// 插入资源
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
    
    func remove(_ resource: VideoItem) -> Bool {
        allVideos.remove(resource)
        try? resource.path?.deleteFile()
        return true
    }
    
    func removeAll() {
        _ = allVideos.map(remove)
    }
    
    /// 切换资源的可用状态
    @discardableResult
    func toggelActive(_ item: VideoItem) -> Bool {
        if activeVideos.contains(item) {
            activeVideos.remove(item)
        } else {
            activeVideos.insert(item)
        }
        playIfNeeded()
        return true
    }
    
    /// 资源是否可用
    func isActive(_ item: VideoItem) -> Bool {
        return activeVideos.contains(item)
    }
    
    func reloadWindows() {
        windows.forEach({ $0.close() })
        windows = NSScreen.screens
            .filter({ $0 == NSScreen.main })
            .map({ ScreenSaverVideoWrapperWindow(screen: $0) })
    }
    
    func playIfNeeded() {
        reloadWindows()
        guard let firstItem = activeVideos.first else { return }
        
        windows.forEach({ window in
            window.videoPlayer?.preparePlayList(Array(activeVideos))
            window.videoPlayer?.play(item: firstItem)
        })
    }
    
    func playModeDidChangeTo(_ newMode: PlayMode) {
        guard newMode == PlayMode.single else { return }
        guard let remain = activeVideos.first else { return }
        activeVideos.removeAll()
        toggelActive(remain)
    }
}

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
