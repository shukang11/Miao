//
//  ScreenSaverVideoWrapperView.swift
//  Miao
//
//  Created by tree on 2021/7/17.
//

import Cocoa
import AVFoundation
import ScreenSaver

class ScreenSaverVideoWrapperView: ScreenSaverView {
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
    }
    
    func setupPlayerLayerIfNeeded(_ player: AVQueuePlayer) {
        wantsLayer = true
        guard let layer = layer else { return }
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        playerLayer.frame = bounds
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class ScreenSaverVideoWrapperWindow: NSWindow {
    
    private var screenSaverView: ScreenSaverVideoWrapperView?
        
    convenience init(screen: NSScreen) {
        let size = screen.frame.size
        let frame = CGRect(origin: .zero, size: size)
        self.init(contentRect: frame, styleMask: .borderless, backing: .buffered, defer: true, screen: screen)
        
        backgroundColor = NSColor(calibratedRed: 0.129, green: 0.118, blue: 0.333, alpha: 1)
        level = NSWindow.Level(Int(CGWindowLevelForKey(.desktopWindow)))
        isReleasedWhenClosed = false
        hidesOnDeactivate = false
        ignoresMouseEvents = true
        orderFront(nil)
        
        guard let contentView = contentView else { return }
        
        screenSaverView = ScreenSaverVideoWrapperView(frame: contentView.bounds, isPreview: false)
        guard let view = screenSaverView else { return }
        view.autoresizingMask = [.width, .height]
        contentView.addSubview(view)
    }
    
    func setupPlayerLayerIfNeeded(_ player: AVQueuePlayer) {
        screenSaverView?.setupPlayerLayerIfNeeded(player)
    }
}
