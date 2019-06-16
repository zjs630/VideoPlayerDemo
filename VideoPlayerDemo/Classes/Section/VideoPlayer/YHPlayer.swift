//
//  YHPlayer.swift
//  VideoPlayerDemo
//
//  Created by ZhangJingshun on 2018/5/20.
//  Copyright © 2018年 一号车市. All rights reserved.
//

import AVFoundation
import UIKit

public enum YHPlayerState: Int {
    case unknown // 播放前
    case error // 出现错误
    case prepareToPlay // 准备播放
    case readyToPlay // 可以播放
    case buffering // 缓冲中
    case bufferEmpty // 缓冲区为空
    case playing // 播放
    case seeking // 切换时间点播放（快进快退）
    case pause // 播放暂停
    case stopped // 播放结束
}

public protocol PlayerDelegate: NSObjectProtocol {
    func player(_ player: YHPlayer, playerStateDidChange status: YHPlayerState)
}

protocol ListCellVideoSuperView: NSObjectProtocol {
    /// cell中播放器视图的SuperView
    var videoSuperView: UIView { set get }
    
//    func addVideoPlayer(view playerView: UIView)
}

extension ListCellVideoSuperView {
    /// 将详情页播放器View添加到cell
    func addVideoPlayer(view playerView: UIView) {
        videoSuperView.addSubview(playerView)
        playerView.frame = videoSuperView.bounds
    }
}

public class YHPlayer: NSObject {
    // MARK: - 属性

    /// 系统播放器
    private var avPlayer: AVPlayer?
    /// 视频播放图层
    private var playerLayer: AVPlayerLayer?
    /// 定时更新播放进度
    private var timeObserver: Any?
    /// 自动隐藏控件Timer
    private var autoHiddenTimer: Timer?
    /// 播放的URL
    var playURL: URL?
    /// 播放器View的父视图
    weak var superView: UIView?
    /// 点击全屏按钮前播放器View的父视图
    weak var embeddedContentView: UIView?
    weak var delegate: PlayerDelegate?
    var indexPath: IndexPath?
    /// 因切换到cell时，tableView会reloadData，主要用于找到对应的cell
    weak var cellTableView: UITableView?
    /// 自动播放
    var autoPlay: Bool = true
    /// 视频长度，live是NaN
    var duration: TimeInterval?

    /// 全屏时播放的controller
    var fullScreenController: YHPlayerFullScreenController?

    var cellRectInWindow: CGRect?
    /// 切换全屏前的视频位置
    var detailRectInWindow: CGRect?
    /// 视频进度
    var currentTime: TimeInterval? {
        return avPlayer?.currentTime
    }

    /// 播放器View
    lazy var playerView: YHVideoPlayerView = {
        let playerView = YHVideoPlayerView()
        playerView.player = self
        return playerView
    }()

    /// 是否正在播放视频
    var isPlaying: Bool {
        guard let avPlayer = avPlayer else {
            return false
        }
        return avPlayer.timeControlStatus == .playing // iOS 10以下，根据rate判断
    }

    /// 播放状态
    var status: YHPlayerState = .unknown {
        didSet {
            // print("old state: \(oldValue) new state: \(status)")
            if oldValue != status {
                switch status {
                case .playing:
                    playerView.changeToPlaying()
                    playerView.playerShowLoading(isShow: false)
                case .readyToPlay, .pause, .stopped, .error:
                    playerView.playerShowLoading(isShow: false)
                default:
                    playerView.playerShowLoading(isShow: true)
                }
                delegate?.player(self, playerStateDidChange: status)
            }
        }
    }

    var playerItem: AVPlayerItem? {
        willSet {
            if playerItem != newValue {
                if let item = playerItem {
                    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
                    item.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
                    item.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
                    item.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackBufferEmpty))
                    item.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackLikelyToKeepUp))
                }
            }
        }
        didSet {
            if playerItem != oldValue {
                if let item = playerItem {
                    NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidPlayToEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
                    item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: NSKeyValueObservingOptions.new, context: nil)
                    item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: NSKeyValueObservingOptions.new, context: nil)
                    // 缓冲区空了，需要等待数据
                    item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackBufferEmpty), options: NSKeyValueObservingOptions.new, context: nil)
                    // 缓冲区有足够数据可以播放了
                    item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackLikelyToKeepUp), options: NSKeyValueObservingOptions.new, context: nil)
                }
            }
        }
    }

    // MARK: - Life cycle

    override init() {
        super.init()
        commonInit()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        releasePlayerResource()
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    // MARK: - 播放控制

    func play(url: String, style: YHPlayStyle = .cell, parentView: UIView) {
        guard let url = URL(string: url) else {
            status = .error
            return
        }
        playURL = url
        superView = parentView
        if autoPlay {
            prepareToPlay()
        }
        playerView.style = style
        if style == .detail { // 详情页播放时自动隐藏
            playerView.isControlsHidden = false
            autoHiddenControls()
        }
    }

    private func prepareToPlay() {
        guard let url = playURL, let parentView = superView else {
            return
        }
        releasePlayerResource()
        status = .prepareToPlay

        playerItem = AVPlayerItem(url: url)
        avPlayer = AVPlayer(playerItem: playerItem)
        let layer = AVPlayerLayer(player: avPlayer)
        parentView.addSubview(playerView)
        playerView.changeData(playerLayer: layer, parrentView: parentView)
        playerLayer = layer
        // 设置加载动画
        playerView.playerShowLoading(isShow: true)
        // 添加定时更新播放进度
        addPlayerItemTimeObserver()
    }

    /// 播放
    func play() {
        if status != .pause { // 否则暂停后再播放，会有一个播放时间的跳动
            playerView.setupPlayProgress()
        }
        status = .playing
        avPlayer?.play()
    }

    /// 重新播放
    func rePlay() {
        seek(to: 0)
    }

    /// 暂停
    func pause() {
        status = .pause
        avPlayer?.pause()
    }

    /// 停止播放
    func stop() {
        status = .stopped
        avPlayer?.pause()
        releasePlayerResource()
    }

    /// 切时间点播放
    func seek(to time: TimeInterval, completionHandler: ((Bool) -> Void)? = nil) {
        guard let avPlayer = self.avPlayer else {
            return
        }
        status = .seeking
        avPlayer.seek(to: CMTimeMakeWithSeconds(time, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { [weak self] finished in
            guard self != nil else {
                return
            }
            self?.status = .playing
            self?.avPlayer?.play() // 重播时需要再次执行play()
            self?.autoHiddenControls() // 隐藏控制控件
            completionHandler?(finished)
        })
    }

    // MARK: - 改变播放器控制样式

    /// 切换到单元格播放样式
    func toCellStyle() {
        playerView.style = .cell
    }

    /// 切换到详情页播放样式
    func toDetailStyle() {
        if let lastStyle = playerView.style {
            if lastStyle == .fullScreen {
                fullToDetail()
            }
        }
        playerView.style = .detail
    }

    /// 从详情页返回到视频列表页
    func detailToCell() {
        guard playerView.style != .cell,
            let tableView = cellTableView else {
            return
        }
        // 先隐藏播放控制
        playerView.isControlsHidden = true
        addPlayerViewToWindow()
        UIView.animate(withDuration: 0.3, animations: {
            // let nr = cellContentView.convert(cellContentView.frame, to: UIApplication.shared.keyWindow)
            // 因nr和原来的frame不一致了，所以对之前的frame进行了保存
            self.playerView.frame = self.cellRectInWindow ?? .zero
        }, completion: { _ in
            self.playerView.removeFromSuperview()
            // 判读是否还存在这个cell，如果不存在，播放其它的如果存在找到对应的cell
            if let playIndex = self.indexPath {
                let isContain = tableView.indexPathsForVisibleRows?.contains(playIndex)
                if isContain == true {
                    if let cell = tableView.cellForRow(at: playIndex) as? UITableViewCell & ListCellVideoSuperView {
                        cell.addVideoPlayer(view: self.playerView)
                        self.playerLayer?.frame = cell.videoSuperView.bounds
                        // 设置播放器类型UI
                        self.playerView.style = .cell
                    } else {
                        printLog("======注意这里没有找到正在播放的cell")
                    }
                }
            }
        })
    }

    /// 将播放器view添加到window
    private func addPlayerViewToWindow() {
        let window = UIApplication.shared.keyWindow
        let rect = playerView.convert(playerView.frame, to: window)
        playerView.removeFromSuperview()
        window?.addSubview(playerView)
        playerView.frame = rect
        // 因返回列表页再次获取时，x,y发生了偏移，所有这里保存下
        if playerView.style == .cell {
            cellRectInWindow = rect
        }
    }

    /// 从列表页到详情页的切换
    func cellToDetail(videoSuperView _: UIView?, tableView: UITableView, detailController: UIViewController, toView detailVSV: UIView) {
        guard playerView.style != .detail,
            let activityViewController = YHPlayerTools.activityViewController() else {
            return
        }
        // 先隐藏播放控制
        playerView.isControlsHidden = true
        cellTableView = tableView

        // 将播放器view添加到window
        addPlayerViewToWindow()
        let nv = UINavigationController(rootViewController: detailController)
        activityViewController.present(nv, animated: false, completion: {
            UIView.animate(withDuration: 0.3, animations: {
                let v = detailVSV
                let nr = v.convert(v.frame, to: UIApplication.shared.keyWindow)
                self.playerView.frame = CGRect(x: 20, y: nr.origin.y, width: nr.size.width, height: nr.size.height)
                self.playerLayer?.frame = self.playerView.bounds
            }, completion: { _ in
                self.playerView.removeFromSuperview()
                detailVSV.addSubview(self.playerView)
                self.superView = detailVSV
                self.playerView.frame = detailVSV.bounds
                self.playerLayer?.frame = detailVSV.bounds

                // 设置播放器类型UI
                self.playerView.style = .detail
                self.autoHiddenControls()
            })
        })
    }

    private func fullToDetail() {
        guard let fullScreenController = fullScreenController,
            let embeddedContentView = embeddedContentView else {
            return
        }
        let rect = fullScreenController.view.bounds
        playerView.removeFromSuperview()
        let window = UIApplication.shared.keyWindow
        window?.addSubview(playerView)

        fullScreenController.dismiss(animated: false, completion: {
            self.playerView.transform = CGAffineTransform(rotationAngle: fullScreenController.currentOrientation == .landscapeLeft ? CGFloat(Double.pi / 2) : -CGFloat(Double.pi / 2))
            self.playerView.frame = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.height, height: rect.size.width)
            UIView.animate(withDuration: 0.3, animations: {
                self.playerView.transform = CGAffineTransform.identity
                self.playerView.frame = self.detailRectInWindow ?? embeddedContentView.bounds
                self.playerLayer?.frame = embeddedContentView.bounds
            }, completion: { _ in
                self.playerView.removeFromSuperview()
                self.embeddedContentView?.addSubview(self.playerView)
                self.playerView.frame = embeddedContentView.bounds
                self.playerLayer?.frame = embeddedContentView.bounds
            })
        })
    }

    /// 切换到全屏样式
    func toFullScreenStyle(_ orientation: UIDeviceOrientation = .landscapeLeft) {
        guard playerView.style != .fullScreen,
            let activityViewController = YHPlayerTools.activityViewController() else {
            return
        }
        // 先隐藏播放控制
        playerView.isControlsHidden = true
        // 设置播放器类型UI
        playerView.style = .fullScreen
        // 保留全屏前播放器的父视图，退出全屏时用到
        embeddedContentView = superView
        detailRectInWindow = playerView.convert(playerView.frame, to: UIApplication.shared.keyWindow)
        fullScreenController = YHPlayerFullScreenController(player: self)
        fullScreenController?.preferredlandscapeForPresentation = orientation == .landscapeRight ? .landscapeLeft : .landscapeRight
        let rect = playerView.convert(playerView.frame, to: activityViewController.view)
        let x = activityViewController.view.bounds.size.width - rect.size.width - rect.origin.x
        let y = activityViewController.view.bounds.size.height - rect.size.height - rect.origin.y
        activityViewController.present(fullScreenController!, animated: false, completion: {
            self.playerView.removeFromSuperview()
            let fullScreenView = self.fullScreenController?.view
            fullScreenView?.addSubview(self.playerView)
            fullScreenView?.sendSubviewToBack(self.playerView)

            self.playerLayer?.frame = fullScreenView?.bounds ?? .zero

            let isRight = orientation == .landscapeRight
            let angle = isRight ? CGFloat(Double.pi / 2) : -CGFloat(Double.pi / 2)
            self.playerView.transform = CGAffineTransform(rotationAngle: angle)

            let rightFrame = CGRect(x: y, y: rect.origin.x, width: rect.size.height, height: rect.size.width)
            let leftFrame = CGRect(x: rect.origin.y, y: x, width: rect.size.height, height: rect.size.width)
            self.playerView.frame = isRight ? rightFrame : leftFrame

            UIView.animate(withDuration: 0.3, animations: {
                self.playerView.transform = CGAffineTransform.identity
                self.playerView.frame = self.fullScreenController!.view.bounds
                self.playerView.center = self.fullScreenController!.view.center
            }, completion: { _ in
                self.playerView.isControlsHidden = false
                self.fullScreenController?.setBackButtonAndTitleLabel(isHidden: false)
            })
        })
    }

    func autoHiddenControls() {
        if autoHiddenTimer != nil {
            autoHiddenTimer?.invalidate()
            autoHiddenTimer = nil
        }
        autoHiddenTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { [weak self] _ in
            guard let strongSelf = self, strongSelf.playerView.progressView.seekBar.isTracking == false else {
                return
            }
            let isHidden = strongSelf.playerView.isControlsHidden
            if isHidden == false && strongSelf.isPlaying {
                strongSelf.playerView.isControlsHidden = true
            }
        })
    }

    // MARK: - 私有方法

    private func commonInit() {
        // 监听屏幕旋转 备用暂时没有用到
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    /// 释放播放器资源
    private func releasePlayerResource() {
        indexPath = nil
        playerItem = nil
        avPlayer?.replaceCurrentItem(with: nil)
        playerLayer = nil

        status = .unknown
        if timeObserver != nil {
            avPlayer?.removeTimeObserver(timeObserver!)
            timeObserver = nil
        }
        if autoHiddenTimer != nil {
            autoHiddenTimer?.invalidate()
            autoHiddenTimer = nil
        }
        printLog("释放播放器资源")
    }
}

// MARK: - KVO

extension YHPlayer {
    private func addPlayerItemTimeObserver() {
        timeObserver = avPlayer?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main, using: { [weak self] _ in
            guard let weakSelf = self else {
                return
            }
            if weakSelf.status == .playing {
                weakSelf.playerView.updateProgress(currentTime: Float(weakSelf.currentTime ?? 0), totalDuration: Float(weakSelf.duration ?? 0))
            }

        })
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        if let item = object as? AVPlayerItem,
            item == self.playerItem,
            let keyPath = keyPath {
            switch keyPath {
            case #keyPath(AVPlayerItem.status):
                printLog("AVPlayerItem's status is changed: \(item.status.rawValue)")
                if item.status == .readyToPlay {
                    if status != .playing {
                        status = .readyToPlay
                    }
                    duration = avPlayer?.duration
                    // 自动播放
                    if autoPlay { // && (lastState == .unknown || lastState == .stopped)
                        play()
                    }
                } else if item.status == .failed {
                    status = .error
                }

            case #keyPath(AVPlayerItem.loadedTimeRanges):
                var progress: Float = 0
                if let duration = duration, let buffer = item.bufferDuration {
                    progress = Float(buffer / duration)
                }
                playerView.updateCacheProgress(progress: progress)
            case #keyPath(AVPlayerItem.playbackBufferEmpty):
                printLog("AVPlayerItem's playbackBufferEmpty is changed \(item.isPlaybackBufferEmpty)")
                if item.isPlaybackBufferEmpty {
                    if status == .buffering {
                        avPlayer?.play()
                    }
                    status = .bufferEmpty
                }
            case #keyPath(AVPlayerItem.playbackLikelyToKeepUp):
                printLog("AVPlayerItem's playbackLikelyToKeepUp is changed \(item.isPlaybackLikelyToKeepUp)")
                let keepUp = item.isPlaybackLikelyToKeepUp
                if !keepUp && status == .playing {
                    status = .buffering
                }
                if keepUp && (status == .buffering || status == .bufferEmpty) {
                    if autoPlay {
                        status = .playing
                    }
                }
            default:
                break
            }
        }
    }
}

// MARK: - 通知

extension YHPlayer {
    @objc fileprivate func playerDidPlayToEnd(_: Notification) {
        status = .stopped
        playerView.changeToPlayEnd()
    }

    @objc fileprivate func deviceOrientationDidChange(_: Notification) {
        // 备用
    }
}
