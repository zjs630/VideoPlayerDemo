//
//  CNDetailVideoViewController.swift
//  YHUser
//
//  Created by 掎角之势 on 2018/5/28.
//  Copyright © 2018年 一号车市. All rights reserved.
//

import UIKit
import WebKit

class CNDetailVideoViewController: CNDetailNormalViewController {
    var videoSuperView = UIView()
    var isFromListNormalController = false
    var iv = UIImageView()
    /// 因用户跳登录页面需要暂停播放
    var isPauseByLogin = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        if isFromListNormalController {
            if let thumbnail = news?.thumbnailBO?.first {
                iv.kf.setImage(with: URL(string: thumbnail), placeholder: UIImage(named: "loading"))
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                let item = MediaItem(url: self.news?.videoUrl, title: self.news?.title ?? "", style: .detail)
                YHMediaManager.sharedInstance.play(mediaItem: item, playView: self.videoSuperView)
                YHMediaManager.sharedInstance.player.delegate = self
            }
        }
    }

    deinit {
        // 主要是侧滑返回，停止视频播放
        if isFromListNormalController && YHMediaManager.sharedInstance.mediaItem != nil {
            YHMediaManager.sharedInstance.releasePlayer()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isPauseByLogin { // 用户是从登录页面返回，接着播放视频
            isPauseByLogin = false
            YHMediaManager.sharedInstance.player.play()
        }
    }

    override func dismissVc() {
        guard let count = navigationController?.children.count, count > 1 else {
            dismiss(animated: true, completion: nil)
            if YHMediaManager.sharedInstance.mediaItem != nil {
                YHMediaManager.sharedInstance.player.detailToCell()
            }
            return
        }
        YHMediaManager.sharedInstance.releasePlayer()
        navigationController?.popViewController(animated: true)
    }

    private func hiddenAndStopVideoPlay() {
        YHMediaManager.sharedInstance.releasePlayer()
        iv.isHidden = true
        webView.snp.removeConstraints()
        webView.snp.makeConstraints({ make in
            make.edges.equalTo(view)
        })
    }

    override func setupScriptMessageHandlers() {
        super.setupScriptMessageHandlers()

        scriptMessageHandlers["noArticle"] = { [weak self] message in
            guard let strongSelf = self else {
                return
            }
            if let stateArticle = message.body as? String {
                if stateArticle != "0" { // 0,表示不隐藏，1表示隐藏
                    if YHMediaManager.sharedInstance.mediaItem == nil { // isFromListNormalController,所以要延迟停止
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.35) {
                            strongSelf.hiddenAndStopVideoPlay()
                        }
                    } else {
                        strongSelf.hiddenAndStopVideoPlay()
                    }
                }
            }
        }
    }

    override func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        super.userContentController(userContentController, didReceive: message)

        let name = message.name
        let player = YHMediaManager.sharedInstance.player
        if name == "login" && player.isPlaying {
            isPauseByLogin = true
            player.pause()
        }
    }

    // MARK: - Orientations

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

// MARK: - 设置UI

extension CNDetailVideoViewController {
    private func setupUI() {
        view.backgroundColor = .white // 防止push到这个页面，会有上个页面的重影

        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        view.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.top.equalTo(18)
            make.right.equalTo(-20)
            let h = 9 * (.screenWidth - 40) / 16
            make.height.equalTo(h)
        }

        view.addSubview(videoSuperView)
        videoSuperView.snp.makeConstraints { make in
            make.edges.equalTo(iv)
        }

        webView.snp.makeConstraints { make in
            make.top.equalTo(videoSuperView.snp.bottom).offset(0)
            make.left.right.bottom.equalTo(0)
        }
    }
}

extension CNDetailVideoViewController: PlayerDelegate {
    func player(_: YHPlayer, playerStateDidChange status: YHPlayerState) {
        switch status {
        case .playing:
            iv.isHidden = true
        case .unknown:
            iv.isHidden = false
        default:
            break
        }
    }
}
