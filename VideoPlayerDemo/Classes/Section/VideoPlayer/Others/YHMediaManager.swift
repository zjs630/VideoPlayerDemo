//
//  YHMediaManager.swift
//  VideoPlayerDemo
//
//  Created by ZhangJingshun on 2018/5/26.
//  Copyright © 2018年 一号车市. All rights reserved.
//

import UIKit
struct MediaItem {
    var url: String?
    var title: String?
    var style: YHPlayStyle
}

class YHMediaManager {
    var player: YHPlayer = YHPlayer()
    weak var embeddedContentView: UIView?
    var mediaItem: MediaItem?

    static let sharedInstance = YHMediaManager()

    func play(mediaItem: MediaItem, playView: UIView) {
        self.mediaItem = mediaItem
        embeddedContentView = playView
        if let urlStr = mediaItem.url {
            player.play(url: urlStr, style: mediaItem.style, parentView: playView)
        }
    }

    func releasePlayer() {
        player.stop()
        player.playerView.changeToWillBegin()
        player.playerView.removeFromSuperview()
        mediaItem = nil
        embeddedContentView = nil
    }
}
