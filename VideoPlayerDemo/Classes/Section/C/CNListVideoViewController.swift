//
//  CVListVideoViewController.swift
//  YHUser
//
//  Created by ZhangJingshun on 2018/5/22.
//  Copyright © 2018年 一号车市. All rights reserved.
//

import UIKit

class CNListVideoViewController: CNListNormalViewController {
    // MARK: - 属性

    private var isViewDisappear = false
    private var isLoadingMore = false // 如果在加载更多的时候，点击了某个cell，更多加载完毕，刷新cell，会导致详情的播放view消失

    var currentIndex: Int = 0 // 防止滑动内容视图时，视频列表预加载，进行视频播放。

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(replayVideo), name: PlayerReplayNotification, object: nil)
        title = "车市头条"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isViewDisappear = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isViewDisappear = true
    }

    /// 刷新列表
    override func refreshList() {
        page = 1
        var dic = [String: String]()
        dic["page"] = "\(page)"
        dic["rows"] = "20"
        dic["channel"] = channel

        CarNewsDataTool.getListByTopic(dic) { [weak self] json in
            guard let this = self else { return }
            this.tableView.mj_header.endRefreshing()
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
                    this.tableView.reloadData()

                    let indexPath = IndexPath(row: 0, section: 0)
                    if let cell = this.tableView.cellForRow(at: indexPath),
                        this.isViewDisappear == false, // 如果用户点击cell进了详情，再下拉刷新数据，就不要再播放第一个视频了
                        this.currentIndex == 3 {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                            if YHNetworkManager.sharedInstance.isWifi {
                                this.playVideo(indexPath: indexPath, cell: cell)
                            }
                        })
                    }
                } catch {
                    Log(error)
                }
            }
        }
    }


    private func playVideo(indexPath: IndexPath, cell: UITableViewCell) {
        let news = carNewses[indexPath.row]
//        let videoUrl = "https://ix86.win:8081/video/e.mp4"
        let item = MediaItem(url: news.videoUrl, title: news.title, style: .cell)
        let vCell = cell as! CarNewsVideoCell
        manager.player.delegate = vCell
        manager.play(mediaItem: item, playView: vCell.videoSuperView)
        manager.player.indexPath = indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isLoadingMore { // 避免刷新导致详情播放视图消失
            return
        }
        if manager.player.indexPath == indexPath {
            playInDetailViewController(indexPath: indexPath)
            return
        }
        // 处理非播放cell的点击
        // 结束正在播放的视频
        if let willPlayCell = tableView.cellForRow(at: indexPath) {
            // print("播放")
            manager.releasePlayer()
            playVideo(indexPath: indexPath, cell: willPlayCell)
            playInDetailViewController(indexPath: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let news = carNewses[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: videoID) as? CarNewsVideoCell
        cell?.set(news: news)
        cell?.indexPath = indexPath

        if let playIndex = manager.player.indexPath,
            manager.player.isPlaying,
            let currentCell = cell {
            if currentCell.indexPath != playIndex && currentCell.videoSuperView.subviews.count > 0 && isViewDisappear == false {
                // 因加载更多导致的刷新可能会出现播放的视频出现在非对应的index Cell
                // playVideo(indexPath: indexPath, cell: currentCell)
                printLog("播放的和当前cell不同")
                manager.releasePlayer()
            }
        }

        return cell!
    }

    private func playInDetailViewController(indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CarNewsVideoCell else {
            return
        }
        // printLog("------ \(indexPath.row)")
        let news = carNewses[indexPath.row]
        let vc = CNDetailVideoViewController()
        vc.news = news
        let newsID = "?mediaId=\(news.mediaId ?? 0)"
        vc.path = NetConfig.host_h5 + NetConfig.Url.carNewsDetails + newsID
        manager.player.cellToDetail(videoSuperView: cell.videoSuperView, tableView: tableView, detailController: vc, toView: vc.videoSuperView)
    }
}

// MARK: - 通知

extension CNListVideoViewController {
    @objc private func replayVideo(_ notifiaction: Notification) {
        if let obj = notifiaction.object as? IndexPath {
            playInDetailViewController(indexPath: obj)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension CNListVideoViewController {
    override func scrollViewDidEndDecelerating(_: UIScrollView) {
        printLog("scrollViewDidEndDecelerating")
        whetherLoadNext()
    }

    override func scrollViewDidEndDragging(_: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            return
        }
        printLog("scrollViewDidEndDragging")
        whetherLoadNext()
    }

    func whetherLoadNext() {
        if let indexPath = YHMediaManager.sharedInstance.player.indexPath {
            let rect = tableView.convert(tableView.rectForRow(at: indexPath), to: tableView.superview)
            if rect.origin.y < -100 || rect.origin.y > UIScreen.main.bounds.height - 240 {
                playNext()
            }
        } else { // 如果当前没有视频播放，滑动后也可以播放
            if YHNetworkManager.sharedInstance.isWifi {
                playNext()
            }
        }
    }

    private func playNext() {
        // 暂停播放
        manager.releasePlayer()
        // 开始下一个。
        var isFind = false // 保证必须播放一个
        if let indexPaths = tableView.indexPathsForVisibleRows {
            for index in indexPaths {
                let cellRect = tableView.convert(tableView.rectForRow(at: index), to: tableView.superview)
                let y = cellRect.origin.y
                if y > -100 && y <= 350 {
                    if let willPlayCell = tableView.cellForRow(at: index) {
                        isFind = true
                        if !YHNetworkManager.sharedInstance.isWifi {
                            return
                        }
                        // 开始播放
                        // print("开始播放")
                        playVideo(indexPath: index, cell: willPlayCell)
                    }
                    break
                }
            }
        }

        if isFind == false {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                // printLog("playNext 播放一个可见的cell ------")
                self.playNext()
            }
        }
    }
}
