//
//  AppDelegate.swift
//  Miao
//
//  Created by tree on 2021/7/16.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusItem()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

extension AppDelegate {
    func setupStatusItem() {
        statusItem.button?.title = "Miao"
        
        let menu = NSMenu()
        menu.addItem(withTitle: "About", action: #selector(onAboutAction(_:)), keyEquivalent: "")
        
        menu.addItem(.separator())
        
        menu.addItem(withTitle: "设置", action: #selector(onPerferenceAction), keyEquivalent: ",")
        
        statusItem.menu = menu
    }
    
    @objc func onAboutAction(_ item: NSMenuItem) {
        NSApp.orderFrontStandardAboutPanel(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func onPerferenceAction() {
        
    }
}
