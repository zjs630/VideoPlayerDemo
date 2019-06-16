//
//  String+Extensions.swift
//  VideoPlayerDemo
//
//  Created by ZhangJingshun on 2018/5/18.
//  Copyright © 2018年 一号车市. All rights reserved.
//

import Foundation
extension String {
    /// 格式化音频视频时长为时间字符串
    ///
    /// - Parameter duration: 时长
    /// - Returns: 时间字符串
    static func yh_convertMedia(time duration: Int32) -> String {
        let h = duration / (60 * 60)
        let ms = duration % (60 * 60)
        let m = ms / 60
        let s = ms % 60
        let time = h > 0 ? String(format: "%.2d:%.2d:%.2d", h, m, s) : String(format: "%.2d:%.2d", m, s)
        return time
    }
}
