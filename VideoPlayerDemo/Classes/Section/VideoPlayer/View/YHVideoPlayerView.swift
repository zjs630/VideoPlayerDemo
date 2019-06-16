//
//  YHVideoPlayerView.swift
//  VideoPlayerDemo
//
//  Created by ZhangJingshun on 2018/5/18.
//  Copyright © 2018年 一号车市. All rights reserved.
//

import AVFoundation
import SnapKit
import UIKit

/// 播放样式
enum YHPlayStyle {
    case cell // 表格中的播放样式
    case detail // 详情页的播放样式
    case fullScreen // 全屏
}

/// 播放器控制条隐藏显示
let PlayerControlsHiddenDidChange = Notification.Name("PlayerControlsHiddenDidChange")
let PlayerReplayNotification = Notification.Name("PlayerReplayNotification")

class YHVideoPlayerView: UIView {
    // MARK: - 属性

    /// 主要控制播放，暂停和重播
    weak var player: YHPlayer?

    /// 播放视频图层
    weak var playerLayer: AVPlayerLayer?
    /// 播放进度视图
    var progressView: YHProgressView!
    /// 加载视图
    var loadingView: YHPlayerLoadingView!
    var videoImageView: UIImageView!
    /// 单击显示隐藏控制
    var singleTapGesture: UITapGestureRecognizer!
    /// 控制器按钮是否隐藏
    var isControlsHidden: Bool = false {
        willSet {
            hiddenControlls(isHidden: newValue)
        }
    }

    /// 播放暂停按钮
    var playPauseButton = UIButton(type: .custom)

    /// 全屏/取消 按钮
    var fullScreenButton = UIButton(type: .custom)
    /// 播放样式
    var style: YHPlayStyle? {
        willSet {
            if let value = newValue, style != newValue {
                updateUIByStyle(style: value)
            }
        }
    }

    // MARK: - 系统方法

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: -

    func changeData(playerLayer layer: AVPlayerLayer, parrentView: UIView) {
        if playerLayer != nil {
            playerLayer?.removeFromSuperlayer()
            playerLayer = nil
        }

        playerLayer = layer
        playerLayer?.frame = parrentView.bounds
        frame = parrentView.bounds
        self.layer.insertSublayer(layer, at: 0)
    }

    // MARK: - 改变UI

    /// 初始化播放进度
    func setupPlayProgress() {
        let duration = player?.duration ?? 0
        progressView?.seekBar.maximumValue = Float(duration)
        progressView?.currentTimeLabel.text = "00:00"
        progressView?.totalTimeLabel.text = String.yh_convertMedia(time: Int32(duration))
    }

    /// 更新播放进度
    func updateProgress(currentTime: Float, totalDuration: Float) {
        if totalDuration > 0 {
            progressView.playProgressView.progress = currentTime / totalDuration
            progressView.currentPlayTime = currentTime
        }
    }

    /// 更新视频缓存进度
    func updateCacheProgress(progress: Float) {
        progressView.cacheProgressView.progress = progress
    }

    /// 播放器是否显示加载动画
    func playerShowLoading(isShow: Bool) {
        if isShow {
            playPauseButton.isHidden = true // 播放旋转动画时，不显示播放按钮
            loadingView.start()
            bringSubviewToFront(loadingView)
        } else {
            loadingView.stop()
        }
    }

    /// 切换到播放状态的UI
    func changeToPlaying() {
        playPauseButton.setImage(UIImage(named: "pause_btn"), for: .normal)
        videoImageView.isHidden = true
        backgroundColor = .black
    }

    /// 切换到播放结束状态
    func changeToPlayEnd() {
        progressView?.currentTimeLabel.text = "00:00"
        progressView.playProgressView.progress = 1
        progressView.seekBar.value = progressView.seekBar.maximumValue
        playPauseButton.setImage(UIImage(named: "replay_btn"), for: .normal)
        if style == .cell {
            playPauseButton.isHidden = false
        } else {
            isControlsHidden = false
        }
        layoutIfNeeded()
    }

    /// 切换到开始前的状态
    func changeToWillBegin() {
        progressView?.currentTimeLabel.text = "00:00"
        progressView.totalTimeLabel.text = ""
        progressView.playProgressView.progress = 0
        progressView.cacheProgressView.progress = 0
        progressView.seekBar.value = 0
    }
}

// MARK: - 私有方法

extension YHVideoPlayerView {
    /// 初始化UI
    private func setupUI() {
        videoImageView = UIImageView()
        videoImageView.contentMode = .scaleAspectFill
        videoImageView.clipsToBounds = true
        addSubview(videoImageView)
        videoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // 当前时间进度Label
        progressView = YHProgressView()
        progressView.seekBar.addTarget(self, action: #selector(seekTime), for: [.valueChanged,.touchCancel])
        addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(40)
        }

        fullScreenButton.setImage(UIImage(named: "fullscreen_btn"), for: .normal)
        fullScreenButton.addTarget(self, action: #selector(fullScreenButtonPressed), for: .touchUpInside)
        addSubview(fullScreenButton)
        fullScreenButton.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(40)
            make.right.equalTo(15)
            make.bottom.equalTo(0)
        }

        // 加载视图
        loadingView = YHPlayerLoadingView()
        addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }

        // 添加播放暂停按钮
        playPauseButton.setImage(UIImage(named: "play_btn"), for: .normal)
        playPauseButton.addTarget(self, action: #selector(playPauseButtonPressed), for: .touchUpInside)
        playPauseButton.isHidden = true
        addSubview(playPauseButton)
        playPauseButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapGestureTapped))
        singleTapGesture.delegate = self
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.numberOfTouchesRequired = 1
        addGestureRecognizer(singleTapGesture)
    }

    // 进度条播放seek
    @objc private func seekTime(_ sender: UISlider) {
        guard let player = player else {
            return
        }
        printLog(sender.value)
        player.seek(to: TimeInterval(sender.value))
    }

    /// 单击播放器
    @objc private func singleTapGestureTapped(_: UIGestureRecognizer) {
        guard player != nil else {
            return
        }
        if style == .detail || style == .fullScreen {
            isControlsHidden = !isControlsHidden
            if player?.isPlaying == true {
                player?.autoHiddenControls()
            }
        }
    }

    // MARK: 改变UI

    /// 隐藏或显示控制按钮,通过isControlsHidden来改变是否显示
    private func hiddenControlls(isHidden: Bool) {
        progressView.isHidden = isHidden
        playPauseButton.isHidden = isHidden
        fullScreenButton.isHidden = isHidden
        if let style = style, style == .fullScreen {
            // 通知controller隐藏返回按钮和标题Label
            NotificationCenter.default.post(name: PlayerControlsHiddenDidChange, object: isHidden)
        }
    }

    /// 通过style来更新UI
    private func updateUIByStyle(style: YHPlayStyle) {
        switch style {
        case .cell:
            isControlsHidden = true
            // 从detail切换到cell模式，如果播放结束，还要显示刷新按钮。
            if progressView.playProgressView.progress == 1 {
                playPauseButton.isHidden = false
                playPauseButton.setImage(UIImage(named: "replay_btn"), for: .normal)
            }
        case .detail:
            isControlsHidden = false
            fullScreenButton.setImage(UIImage(named: "fullscreen_btn"), for: .normal)
            fullScreenButton.snp.updateConstraints { make in
                make.right.equalTo(15)
                make.bottom.equalTo(0)
            }
        case .fullScreen:
            fullScreenButton.setImage(UIImage(named: "normalscreen_btn"), for: .normal)
            fullScreenButton.snp.updateConstraints { make in
                make.right.equalTo(-20)
                make.bottom.equalTo(-10)
            }
        }
        progressView.updateStyle(style: style)
    }

    // MARK: 按钮点击事件

    @objc private func playPauseButtonPressed() {
        guard let player = self.player else {
            return
        }
        if player.isPlaying {
            playPauseButton.setImage(UIImage(named: "play_btn"), for: .normal)
            player.pause()
            return
        }
        // 非播放状态
        if player.status == .stopped {
            playPauseButton.setImage(UIImage(named: "play_btn"), for: .normal)
            playPauseButton.isHidden = true
            player.rePlay()
            if style == .cell { // 列表模式播放，暂停后，刷新跳转到详情页播放
                NotificationCenter.default.post(name: PlayerReplayNotification, object: player.indexPath)
            } else {
                player.autoHiddenControls() // 重播也自动隐藏按钮
            }
        } else {
            playPauseButton.setImage(UIImage(named: "pause_btn"), for: .normal)
            player.play()
            player.autoHiddenControls()
        }
    }

    @objc private func fullScreenButtonPressed() {
        guard let style = style else {
            return
        }
        switch style {
        case .detail:
            player?.toFullScreenStyle(UIDevice.current.orientation)
        case .fullScreen:
            player?.toDetailStyle()
        default:
            break
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension YHVideoPlayerView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_: UIGestureRecognizer, shouldReceive _: UITouch) -> Bool {
        if style == .cell { // 列表页不响应单击事件
            return false
        }
        return true
    }
}
