//
//  ResourceType.swift
//  Miao
//
//  Created by tree on 2021/7/21.
//

import Foundation
import AVFoundation

protocol PlayResourceGenratorType {
    func generatePlayItem() -> AVPlayerItem
}

protocol ResourceType: PlayResourceGenratorType, Codable, AnyObject {
    var uuid: UUID { get }
    
    var name: String { get }
}
