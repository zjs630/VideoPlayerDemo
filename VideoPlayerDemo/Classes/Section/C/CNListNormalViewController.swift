//
//  CVListNormalViewController.swift
//  YHUser
//
//  Created by 掎角之势 on 2018/5/22.
//  Copyright © 2018年 一号车市. All rights reserved.
//

import UIKit

class CNListNormalViewController: UITableViewController, Refreshable, ErrorViewable {
    func loadMore() {
        
    }
    
    var refreshView: UIScrollView {
        return tableView
    }

    /// 网络异常视图
    lazy var errorView: ErrorView = {
        let errorView = ErrorView()
        errorView.size = CGSize(width: .screenWidth, height: .screenHeight - 49 - 104)
        errorView.delegate = self
        errorView.displayType = .hidden
        errorView.backgroundColor = .mainBG
        return errorView

    }()

    /// 列表页码
    var page: Int = 1
    var channel = "1"
    /// 列表数据源
    var carNewses = [CarNews]()
    private let oneIMGID = "oneIMG"
    private let multiIMGID = "multiIMG"
    let videoID = "video"
    let manager = YHMediaManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        setupRefresh()

        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor(0xEEEEEE)
        tableView.backgroundColor = .mainBG
        tableView.estimatedRowHeight = 200
        tableView.addSubview(errorView)

        tableView.register(CarNewsOneIMGCell.self, forCellReuseIdentifier: oneIMGID)
        tableView.register(CarNewsMultiIMGCell.self, forCellReuseIdentifier: multiIMGID)
        tableView.register(CarNewsVideoCell.self, forCellReuseIdentifier: videoID)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return carNewses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let news = carNewses[indexPath.row]
        switch news.type ?? 0 {
        case 2: // 视频
            var cell = tableView.dequeueReusableCell(withIdentifier: videoID) as? CarNewsVideoCell
            if cell == nil {
                cell = CarNewsVideoCell(style: .default, reuseIdentifier: videoID)
            }
            cell?.set(news: news)
            return cell!
        default: // 文章
            if (news.thumbnailBO?.count ?? 0) < 3 { // 单图
                var cell = tableView.dequeueReusableCell(withIdentifier: oneIMGID) as? CarNewsOneIMGCell
                if cell == nil {
                    cell = CarNewsOneIMGCell(style: .default, reuseIdentifier: oneIMGID)
                }
                cell?.set(news: news)
                return cell!
            } else { // 多图
                var cell = tableView.dequeueReusableCell(withIdentifier: multiIMGID) as? CarNewsMultiIMGCell
                if cell == nil {
                    cell = CarNewsMultiIMGCell(style: .default, reuseIdentifier: multiIMGID)
                }
                cell?.set(news: news)
                return cell!
            }
        }
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let web: CNDetailNormalViewController!
        let news = carNewses[indexPath.row]

        switch news.type ?? 0 {
        case 2:
            let lweb = CNDetailVideoViewController()
            lweb.isFromListNormalController = true
            web = lweb
        default:
            web = CNDetailNormalViewController()
        }
        news.pvNum = (news.pvNum ?? 0) + 1 // 本地阅读量+1
        web.news = news
        let newsID = "?mediaId=\(news.mediaId ?? 0)"
        web.path = NetConfig.host_h5 + NetConfig.Url.carNewsDetails + newsID
        web.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(web, animated: true)
    }

    func didCilicked(errorView _: ErrorView) {
        tableView.mj_header?.beginRefreshing()
    }

    /// 刷新列表
    func refreshList() {
        page = 1

        var dic = [String: String]()
        dic["page"] = "\(page)"
        dic["rows"] = "20"
        dic["channel"] = channel

        CarNewsDataTool.getListByTopic(dic) { [weak self] json in

            guard let this = self else { return }

            this.tableView.mj_header?.endRefreshing()

            guard let result = ((try? json?["result"]["rows"].rawData()) as Data??) else {
                this.tableView.reloadData()

                this.errorView.isHidden = !(this.carNewses.count == 0)
                this.tableView.bringSubviewToFront(this.errorView)

                return
            }

            if let res = result {
                do {
                    let cns = try JSONDecoder().decode([CarNews].self, from: res)
                    this.errorView.isHidden = true
                    this.carNewses = cns
                } catch {
                    Log(error)
                }
            }
            this.tableView.reloadData()

        }
    }

}
