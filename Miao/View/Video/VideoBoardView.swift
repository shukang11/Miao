//
//  VideoPreview.swift
//  Miao
//
//  Created by tree on 2021/7/19.
//

import SwiftUI

struct VideoBoardView: View {
    
    @ObservedObject var manager: MediaResourceManager
    
    var body: some View {
        HStack {
            VStack {
                List {
                    ForEach(manager.resources.indices, id: \.self) { i in
                        let item: VideoItem = manager.resources[i]
                        VideoPreviewItem(item: item, selected: manager.isActive(item))
                        Divider()
                    }
                }
                HStack{
                    Spacer()
                    Button("+") {
                        openPanelAction()
                    }
                    Button("清空") {
                        MediaResourceManager.shared.removeAll()
                    }
                }
                Spacer(minLength: 20)
            }
        }
        .padding(.horizontal, 20.0)
        
    }
    
    func openPanelAction() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
//        panel.canChooseDirectories = true
        panel.allowedFileTypes = ["mp4"]
        panel.allowsMultipleSelection = true
        let finded = panel.runModal()
        guard finded == .OK else { return }
        _ = panel.urls
            .map(VideoItem.init)
            .map(MediaResourceManager.shared.insert)
    }
    
}

struct VideoPreview_Previews: PreviewProvider {
    static var previews: some View {
        VideoBoardView(manager: MediaResourceManager.shared)
    }
}
