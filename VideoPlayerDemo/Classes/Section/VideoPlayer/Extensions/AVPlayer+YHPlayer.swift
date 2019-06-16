//
//  AVPlayer+YHPlayer.swift
//  VideoPlayerDemo
//
//  Created by ZhangJingshun on 2018/5/20.
//  Copyright © 2018年 一号车市. All rights reserved.
//

import AVFoundation
public extension AVPlayer {
    /// 观看了的时长（不包括暂停等）
    var durationWatched: TimeInterval {
        var duration: TimeInterval = 0
        if let events = self.currentItem?.accessLog()?.events {
            for event in events {
                duration += event.durationWatched
            }
        }
        return duration
    }

    /// 总时长
    var duration: TimeInterval? {
        if let duration = self.currentItem?.duration {
            return CMTimeGetSeconds(duration)
        }
        return nil
    }

    /// 播放进度
    var currentTime: TimeInterval? {
        return CMTimeGetSeconds(self.currentTime())
    }
}
