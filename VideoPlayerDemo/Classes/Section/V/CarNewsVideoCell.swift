//
//  CarNewsVideoCell.swift
//  YHNewsVideo
//
//  Created by 张京顺 on 2019/6/16.
//  Copyright © 2019 一号车市. All rights reserved.
//

import UIKit


class CarNewsVideoCell: BasicTableViewCell, PlayerDelegate, ListCellVideoSuperView {
    let title = UILabel()
    let iv = UIImageView()
    var videoSuperView = UIView()
    let playIv = UIImageView()
    let bar = NewsBar()
    var indexPath: IndexPath?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        title.font = UIFont.systemFont(ofSize: 17)
        title.textColor = UIColor(0x000000)
        title.numberOfLines = 2
        contentView.addSubview(title)
        title.snp.makeConstraints { maker in
            maker.top.equalTo(18)
            maker.left.equalTo(20)
            maker.right.equalTo(-20)
        }
        
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .black
        iv.clipsToBounds = true
        contentView.addSubview(iv)
        iv.snp.makeConstraints { maker in
            maker.top.equalTo(title.snp.bottom).offset(10)
            maker.left.equalTo(20)
            maker.right.equalTo(-20)
            let h = 9 * (.screenWidth - 40) / 16
            maker.height.equalTo(h)
        }
        
        contentView.addSubview(videoSuperView)
        videoSuperView.snp.makeConstraints { make in
            make.edges.equalTo(iv)
        }
        
        playIv.contentMode = .scaleAspectFill
        playIv.image = UIImage(named: "play_btn")
        iv.addSubview(playIv)
        playIv.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }
        
        contentView.addSubview(bar)
        bar.snp.makeConstraints { maker in
            maker.top.equalTo(iv.snp.bottom).offset(10)
            maker.bottom.equalTo(-10)
            maker.right.equalTo(-20)
            maker.left.equalTo(20)
        }
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(news n: CarNews) {
        title.text = n.title
        if let thumbnail = n.thumbnailBO?.first {
            iv.kf.setImage(with: URL(string: thumbnail), placeholder: UIImage(named: "loading"))
        }
        bar.set(news: n)
        changeControls(isHidden: false)
    }
    
    func player(_: YHPlayer, playerStateDidChange status: YHPlayerState) {
        switch status {
        case .prepareToPlay:
            playIv.isHidden = true
        case .playing:
            changeControls(isHidden: true)
        case .unknown:
            changeControls(isHidden: false)
        default:
            break
        }
    }
    
    private func changeControls(isHidden: Bool) {
        iv.isHidden = isHidden
        playIv.isHidden = isHidden
    }
}
