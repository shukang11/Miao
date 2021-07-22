//
//  VideoPreviewCell.swift
//  Miao
//
//  Created by tree on 2021/7/21.
//

import Foundation
import SwiftUI

struct VideoPreviewItem: View {
    
    let item: VideoItem
        
    var selected: Bool
    
    var body: some View {
        HStack(alignment: .center) {
            Button.init(action: {
                MediaResourceManager.shared.toggelActive(item)
            }, label: {
                selected ? Text("当前") : Text("设定")
            })
            
            Image(decorative: item.thumbnail(size: CGSize(width: 800, height: 600), second: 4), scale: 0.5)
                .resizable()
                .frame(width: 80.0, height: 60.0)
                .aspectRatio(contentMode: .fit)
            
            VStack(alignment: .leading) {
                Text(item.name)
                Text(item.uuid.uuidString).padding(.top)
            }.padding(EdgeInsets())
        }
        .frame(width: nil, height: 70.0)
    }
    
}

struct VideoPreviewItem_Previews: PreviewProvider {
    static var previews: some View {
        let path = Bundle.main.path(forResource: "5bbadd3466e1f3205b7e4e98", ofType: "mp4")!
        VideoPreviewItem(item: VideoItem.init(url: URL(fileURLWithPath: path)), selected: true)
    }
}
