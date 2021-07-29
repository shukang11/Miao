//
//  AppDelegate.swift
//  Miao
//
//  Created by tree on 2021/7/16.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    private var displayWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusItem()
        onPerferenceAction()
        MediaResourceManager.shared.launch()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

}

extension AppDelegate {
    func setupStatusItem() {
        statusItem.button?.title = "⏳"
        
        let menu = NSMenu()
        menu.addItem(withTitle: "About", action: #selector(onAboutAction(_:)), keyEquivalent: "")
        
        menu.addItem(.separator())
        
        menu.addItem(withTitle: "设置", action: #selector(onPerferenceAction), keyEquivalent: ",")
        menu.addItem(withTitle: "退出", action: #selector(onExitAction), keyEquivalent: "")
        statusItem.menu = menu
    }
    
    @objc func onExitAction() {
        NSApp.terminate(self)
    }
    
    @objc func onAboutAction(_ item: NSMenuItem) {
        NSApp.orderFrontStandardAboutPanel(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func onPerferenceAction() {
        let frame: CGRect
        if let windowFrame = NSScreen.main?.frame {
            let scale: CGFloat = 0.5
            frame = CGRect(x: 0, y: 0, width: windowFrame.width * scale, height: windowFrame.height * scale)
        } else {
            frame = CGRect(origin: .zero, size: CGSize(width: 400, height: 300))
        }
        let style: NSWindow.StyleMask = [.titled, .closable, .fullSizeContentView]
        displayWindow?.close()
        displayWindow = nil
        let newWindow: NSWindow = NSWindow(
            contentRect: frame,
            styleMask: style,
            backing: .buffered,
            defer: false
        )
        displayWindow = newWindow
        displayWindow?.isReleasedWhenClosed = false
        displayWindow?.titlebarAppearsTransparent = true
        displayWindow?.center()
        let content = NSHostingView(rootView: SettingRootView())
        displayWindow?.contentView = content
        displayWindow?.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func onVideoAction() {
        
    }
    
    
}

extension AppDelegate: NSToolbarDelegate {
    
    //实际显示的item 标识
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [NSToolbarItem.Identifier.WallPaper, NSToolbarItem.Identifier.Setting]
    }
    
    //所有的item 标识,在编辑模式下会显示出所有的item
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [NSToolbarItem.Identifier.WallPaper, NSToolbarItem.Identifier.Setting]
    }
    
    //根据item 标识 返回每个具体的NSToolbarItem对象实例
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        
        let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        if itemIdentifier == NSToolbarItem.Identifier.WallPaper {
            toolbarItem.label = "WallPaper"
            toolbarItem.paletteLabel = "WallPaper"
            toolbarItem.toolTip = "WallPaper Setting"
            toolbarItem.image = NSImage.init(named: NSImage.Name.WallPaper)
            toolbarItem.tag = 1
        }
        if itemIdentifier == NSToolbarItem.Identifier.Setting {
            toolbarItem.label = "Setting"
            toolbarItem.paletteLabel = "Setting"
            toolbarItem.toolTip = "Setting"
            toolbarItem.image = NSImage.init(named: NSImage.Name.Setting)
            toolbarItem.tag = 2
        }
        
        toolbarItem.minSize = NSSize(width: 25, height: 25)
        toolbarItem.maxSize = NSSize(width: 100, height: 100)
        toolbarItem.target = self
        toolbarItem.action = #selector(AppDelegate.toolbarItemClicked(_:))
        return toolbarItem
    }
}

extension AppDelegate {
    @objc func toolbarItemClicked(_ sender: NSToolbarItem) {
        
    }
}

extension NSToolbar.Identifier {
    public static let AppToolbar: NSToolbar.Identifier =  NSToolbar.Identifier("AppToolbar")
}

extension NSToolbarItem.Identifier {
    public static let WallPaper: NSToolbarItem.Identifier =  NSToolbarItem.Identifier(rawValue: "WallPaper")
    public static let Setting: NSToolbarItem.Identifier =  NSToolbarItem.Identifier(rawValue: "Setting")
}

extension  NSImage.Name {
    public static let WallPaper:  NSImage.Name =   NSImage.Name("wallpaper")
    public static let Setting:  NSImage.Name =   NSImage.Name("setting")
}
