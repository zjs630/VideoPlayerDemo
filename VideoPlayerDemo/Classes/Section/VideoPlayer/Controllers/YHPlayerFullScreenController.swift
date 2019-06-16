//
//  YHPlayerFullScreenController.swift
//  VideoPlayerDemo
//
//  Created by ZhangJingshun on 2018/5/24.
//  Copyright © 2018年 一号车市. All rights reserved.
//

import SnapKit
import UIKit

class YHPlayerFullScreenController: UIViewController {
    weak var player: YHPlayer?
    var preferredlandscapeForPresentation = UIInterfaceOrientation.landscapeLeft
    var currentOrientation = UIDevice.current.orientation
    let backButton = UIButton(type: .custom)
    let titleLabel = UILabel()

    /// 全屏隐藏状态栏
    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - 系统方法

    convenience init(player: YHPlayer) {
        self.init()
        self.player = player
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(playerControlsHiddenDidChange), name: PlayerControlsHiddenDidChange, object: nil)

        setupUI()
    }

    deinit {
        printLog("")
    }

    // MARK: - Orientations
    open override var shouldAutorotate: Bool {
        return true
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeLeft, .landscapeRight]
    }

    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        currentOrientation = preferredlandscapeForPresentation == .landscapeLeft ? .landscapeRight : .landscapeLeft
        return preferredlandscapeForPresentation
    }

    // MARK: - 按钮点击事件

    @objc private func backAction() {
        player?.toDetailStyle()
    }

    // MARK: - notification

    @objc func playerControlsHiddenDidChange(_ notifiaction: Notification) {
        if let isHidden = notifiaction.object as? Bool {
            setBackButtonAndTitleLabel(isHidden: isHidden)
        }
    }
}

// MARK: - 设置UI

extension YHPlayerFullScreenController {
    private func setupUI() {
        view.backgroundColor = UIColor.black

        backButton.setImage(UIImage(named: "nav_back"), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(11)
            make.width.height.equalTo(48)
        }

        titleLabel.font = UIFont.systemFont(ofSize: 21)
        titleLabel.textColor = UIColor.white
        titleLabel.text = YHMediaManager.sharedInstance.mediaItem?.title ?? ""
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(backButton.snp.right).offset(-4)
            make.right.equalTo(-20)
            make.centerY.equalTo(backButton)
        }
        setBackButtonAndTitleLabel(isHidden: true)
    }

    /// 设置返回按钮和标题的隐藏
    func setBackButtonAndTitleLabel(isHidden: Bool) {
        backButton.isHidden = isHidden
        titleLabel.isHidden = isHidden
    }
}
