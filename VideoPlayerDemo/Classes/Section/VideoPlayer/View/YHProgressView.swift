//
//  YHProgressView.swift
//  VideoPlayerDemo
//
//  Created by ZhangJingshun on 2018/5/18.
//  Copyright © 2018年 一号车市. All rights reserved.
//

import SnapKit
import UIKit

/// 播放进度视图，可以控制播放进度，显示当前播放进度及播放时长
class YHProgressView: UIView {
    /// 当前时间Label
    var currentTimeLabel: UILabel!
    /// 播放时长
    var totalTimeLabel: UILabel!
    /// 显示播放进度及控制，在cell中播放时不显示，
    var seekBar: UISlider!
    /// 数据播放进度，在cell中播放时显示，
    var playProgressView: UIProgressView!
    /// 数据缓冲进度
    var cacheProgressView: UIProgressView!

    var currentPlayTime: Float = 0 {
        willSet {
            currentTimeLabel.text = String.yh_convertMedia(time: Int32(newValue))
            if !seekBar.isTracking {
                seekBar.value = newValue
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func playoverStatus() {
        currentTimeLabel.text = "00:00"
        seekBar.value = 0
    }

    private func setupUI() {
        let tintColor = UIColor(red: 1.0, green: 0x97 / 255.0, blue: 0, alpha: 1.0)
        // 当前时间进度Label
        currentTimeLabel = UILabel()
        currentTimeLabel.textAlignment = .left
        currentTimeLabel.font = UIFont.systemFont(ofSize: 12)
        currentTimeLabel.textColor = UIColor.white
        addSubview(currentTimeLabel)
        // 缓冲进度条
        cacheProgressView = UIProgressView()
        cacheProgressView.progress = 0
        cacheProgressView.progressTintColor = UIColor(red: 245.0 / 255, green: 245.0 / 255, blue: 245.0 / 255, alpha: 1.0)
        cacheProgressView.trackTintColor = UIColor.clear
        cacheProgressView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        addSubview(cacheProgressView)

        // 播放进度条（没有滑块控制）
        playProgressView = UIProgressView()
        playProgressView.progress = 0
        playProgressView.progressTintColor = tintColor
        playProgressView.trackTintColor = UIColor.clear
        playProgressView.backgroundColor = UIColor.clear
        addSubview(playProgressView)

        // 详情播放进度条
        seekBar = UISlider()
        seekBar.minimumValue = 0
        seekBar.value = 0
        seekBar.isContinuous = false
        // seekBar.maximumValue = Float(player.player!.duration);
        seekBar.minimumTrackTintColor = tintColor
        seekBar.maximumTrackTintColor = UIColor.clear
//        seekBar.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        seekBar.setThumbImage(UIImage(named: "slider_thumb"), for: .normal)
        addSubview(seekBar)

        // 视频总长时间Label
        totalTimeLabel = UILabel()
        totalTimeLabel.font = UIFont.systemFont(ofSize: 12)
        totalTimeLabel.textColor = UIColor.white
        addSubview(totalTimeLabel)
    }

    // MARK: - 设置样式

    func updateStyle(style: YHPlayStyle) {
        switch style {
        case .cell:
            cellStyle()
        case .detail:
            detailStyle()
        case .fullScreen:
            fullStyle()
        }
    }
}

// MARK: - 私有方法

extension YHProgressView {
    private func cellStyle() {
        isHidden = false
        currentTimeLabel.isHidden = true
        totalTimeLabel.isHidden = true
        seekBar.isHidden = true
        playProgressView.isHidden = false

        cacheProgressView.snp.removeConstraints()
        cacheProgressView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(2)
        }

        playProgressView.snp.removeConstraints()
        playProgressView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(2)
        }
    }

    private func detailStyle() {
        controlsHiddenDefault()

        // 设置当前时间Label的约束
        currentTimeLabel.snp.removeConstraints()
        currentTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(self).offset(7)
            make.width.equalTo(36)
            make.centerY.equalTo(self)
        }

        seekBar.snp.removeConstraints()
        seekBar.snp.makeConstraints { make in
            make.left.equalTo(currentTimeLabel.snp.right).offset(5)
            make.top.equalTo(15)
        }

        cacheProgressView.snp.removeConstraints()
        cacheProgressView.snp.makeConstraints { make in
            make.left.right.equalTo(seekBar)
            make.centerY.equalTo(self)
            make.height.equalTo(2)
        }
        // 设置时长Label的约束
        totalTimeLabel.snp.removeConstraints()
        totalTimeLabel.snp.makeConstraints { make in
            make.right.equalTo(self).offset(-30)
            make.centerY.equalTo(self)
            make.left.equalTo(seekBar.snp.right).offset(5)
        }
        snp.updateConstraints { make in
            make.bottom.equalTo(0)
        }
    }

    private func fullStyle() {
        controlsHiddenDefault()
        currentTimeLabel.snp.removeConstraints()
        currentTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(self).offset(30)
            make.width.equalTo(36)
            make.centerY.equalTo(self)
        }

        seekBar.snp.removeConstraints()
        seekBar.snp.makeConstraints { make in
            make.left.equalTo(currentTimeLabel.snp.right).offset(10)
            make.top.equalTo(15)
        }

        cacheProgressView.snp.removeConstraints()
        cacheProgressView.snp.makeConstraints { make in
            make.left.right.equalTo(seekBar)
            make.centerY.equalTo(self)
            make.height.equalTo(2)
        }

        totalTimeLabel.snp.removeConstraints()
        totalTimeLabel.snp.makeConstraints { make in
            make.right.equalTo(self).offset(-80)
            make.centerY.equalTo(self)
            make.left.equalTo(seekBar.snp.right).offset(10)
        }

        snp.updateConstraints { make in
            make.bottom.equalTo(-10)
        }
    }

    /// 设置detail和full模式下的控件隐藏
    private func controlsHiddenDefault() {
        currentTimeLabel.isHidden = false
        totalTimeLabel.isHidden = false
        seekBar.isHidden = false
        playProgressView.isHidden = true
    }
}
