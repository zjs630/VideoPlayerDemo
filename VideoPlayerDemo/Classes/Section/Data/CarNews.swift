//
//  CarNews.swift
//  YHUser
//
//  Created by 掎角之势 on 2018/5/23.
//  Copyright © 2018年 一号车市. All rights reserved.
//

import UIKit

class CarNews: Codable {
    /// 作者    string
    var author: String?
    /// 栏目：1=推荐,2=二手车,3=资讯,4=视频    number
    var channel: Int?
    /// 评论数    number
    var commentNum: Int?
    /// 文章内容/视频地址    string
    var content: String?
    /// 资讯ID    number
    var mediaId: Int?
    /// 点赞数    number
    var praiseNum: Int?
    /// 发布日期    string    long时间戳
    var publishTimeBO: Double?
    /// 页面浏览数    number
    var pvNum: Int?
    /// 分享后下载数    number
    var shareDownloadNum: Int?
    /// 资讯来源    string
    var sourceName: String?
    /// 状态：0=未发布,1=已发布,2=已取消    number
    var status: Int?
    /// 缩略图/视频预览图    array<string>
    var thumbnailBO: [String]?
    /// 标题    string
    var title: String?
    /// 类型：1=文章,2=视频    number
    var type: Int?
    /// 最近操作时间    string    long 时间戳
    var updateTimeBO: Int?
    /// 视频地址
    var videoUrl: String?
}
