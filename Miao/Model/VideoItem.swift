//
//  PlayItem.swift
//  Miao
//
//  Created by tree on 2021/7/16.
//

import Foundation
import AVFoundation
import FileKit

final class VideoItem: ResourceType, Codable, ObservableObject, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.url)
    }
    
    static func == (lhs: VideoItem, rhs: VideoItem) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    let name: String
    
    let uuid: UUID
    
    let url: URL
    
    var selected: Bool = false
    
    var path: Path? {
        if url.isFileURL {
            return Path(url.absoluteString)
        }
        return nil
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: VideoItem.CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        uuid = try container.decode(UUID.self, forKey: .uuid)
        url = try container.decode(URL.self, forKey: .url)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: VideoItem.CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(url, forKey: .url)
        try container.encode(uuid, forKey: .uuid)
    }
    
    convenience init(url: URL) {
        let uuid = UUID()
        let name = url.lastPathComponent
        self.init(url: url, uuid: uuid, name: name)
    }
    
    convenience init(path: Path) {
        self.init(url: path.url, uuid: UUID(), name: path.fileName)
    }
    
    init(url: URL, uuid: UUID, name: String) {
        self.url = url
        self.uuid = uuid
        self.name = name
    }
    
    func generatePlayItem() -> AVPlayerItem {
        return AVPlayerItem(url: url)
    }
    
    func thumbnail(size: CGSize, second: Double = 0.0) -> CGImage {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = size
        var actualTime = CMTimeMake(value: 0, timescale: 0)
        let safeSecond: Double = min(asset.duration.seconds, second)
        let time: CMTime = CMTime.init(seconds: safeSecond, preferredTimescale: 600)
        let imageRef = try! generator.copyCGImage(at: time, actualTime: &actualTime)
        return imageRef
    }
}

extension VideoItem {
    enum CodingKeys: String, CodingKey {
        case url
        case name
        case uuid
    }
}
