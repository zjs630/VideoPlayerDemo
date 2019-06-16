//
//  YHProtocols.swift
//  YHUser
//
//  Created by 掎角之势 on 2017/9/5.
//  Copyright © 2017年 一号车市. All rights reserved.
//

import Foundation
import UIKit

/// 下拉刷新、上拉加载更多
protocol Refreshable {
    /// 需要刷新的视图
    var refreshView: UIScrollView { get }

    /// 页面
    var page: Int { get set }

    /// 集成刷新控件
    func setupRefresh()

    /// 下拉刷新
    func refreshList()

    /// 加载更多
    func loadMore()
}

extension Refreshable where Self: UIViewController {
    /// 集成刷新控件
    func setupRefresh() {
        let header = MJChiBaoZiHeader { [weak self] in
            self?.refreshList()
        }
        header?.lastUpdatedTimeLabel.isHidden = true
        header?.labelLeftInset = 5
        header?.stateLabel.font = UIFont.systemFont(ofSize: 12)
        header?.stateLabel.textColor = UIColor(0x666666)
        header?.backgroundColor = .mainBG

        refreshView.mj_header = header

        refreshView.mj_header.beginRefreshing()

//        let footer = MJRefreshAutoStateFooter { [weak self] in
//            self?.loadMore()
//        }
//        footer?.stateLabel.font = UIFont.systemFont(ofSize: 13)
//        footer?.stateLabel.textColor = UIColor(0x666666)
//        footer?.isHidden = true
//        refreshView.mj_footer = footer
    }
}
