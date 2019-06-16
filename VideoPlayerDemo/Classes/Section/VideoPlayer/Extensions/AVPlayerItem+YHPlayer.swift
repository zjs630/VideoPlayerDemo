//
//  AVPlayerItem+YHPlayer.swift
//  VideoPlayerDemo
//
//  Created by ZhangJingshun on 2018/5/20.
//  Copyright © 2018年 一号车市. All rights reserved.
//

import AVFoundation
public extension AVPlayerItem {
    var bufferDuration: TimeInterval? {
        if let first = self.loadedTimeRanges.first { // 获取缓冲进度
            let timeRange = first.timeRangeValue // 获取缓冲区域
            let startSeconds = CMTimeGetSeconds(timeRange.start) // 开始的时间
            let durationSecound = CMTimeGetSeconds(timeRange.duration) // 表示已经缓冲的时间
            let result = startSeconds + durationSecound // 计算缓冲总时间
            return result
        }
        return nil
    }
}
