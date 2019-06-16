//
//  CarNewsCell.swift
//  YHUser
//
//  Created by 掎角之势 on 2018/5/23.
//  Copyright © 2018年 一号车市. All rights reserved.
//

import UIKit
import Kingfisher

private let imgWidth = (.screenWidth - 20 * 2 - 3 * 2) / 3
private let imgHeight = imgWidth / 2

class CarNewsOneIMGCell: BasicTableViewCell {
    let title = UILabel()
    let iv = UIImageView()
    let bar = NewsBar()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        title.font = UIFont.systemFont(ofSize: 17)
        title.textColor = UIColor(0x000000)
        title.numberOfLines = 2
        contentView.addSubview(title)
        title.snp.makeConstraints { maker in
            maker.top.equalTo(18)
            maker.left.equalTo(20)
        }

        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        contentView.addSubview(iv)
        iv.snp.makeConstraints { maker in
            maker.top.equalTo(18)
            maker.left.equalTo(title.snp.right)
            maker.right.equalTo(-20)
            maker.size.equalTo(CGSize(width: imgWidth, height: imgHeight))
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
    }
}

class CarNewsMultiIMGCell: BasicTableViewCell {
    let title = UILabel()
    let iv1 = UIImageView()
    let iv2 = UIImageView()
    let iv3 = UIImageView()
    let bar = NewsBar()

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

        iv1.contentMode = .scaleAspectFill
        iv1.clipsToBounds = true
        contentView.addSubview(iv1)
        iv1.snp.makeConstraints { maker in
            maker.top.equalTo(title.snp.bottom).offset(10)
            maker.left.equalTo(title.snp.left)
            maker.size.equalTo(CGSize(width: imgWidth, height: imgHeight))
        }

        iv2.contentMode = .scaleAspectFill
        iv2.clipsToBounds = true
        contentView.addSubview(iv2)
        iv2.snp.makeConstraints { maker in
            maker.top.equalTo(iv1.snp.top)
            maker.left.equalTo(iv1.snp.right).offset(3)
            maker.size.equalTo(CGSize(width: imgWidth, height: imgHeight))
        }

        iv3.contentMode = .scaleAspectFill
        iv3.clipsToBounds = true
        contentView.addSubview(iv3)
        iv3.snp.makeConstraints { maker in
            maker.top.equalTo(iv2.snp.top)
            maker.left.equalTo(iv2.snp.right).offset(3)
            maker.size.equalTo(CGSize(width: imgWidth, height: imgHeight))
        }

        contentView.addSubview(bar)
        bar.snp.makeConstraints { maker in
            maker.top.equalTo(iv1.snp.bottom).offset(10)
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

        for (i, thumbnail) in (n.thumbnailBO ?? [String]()).enumerated() {
            switch i {
            case 0:
                iv1.kf.setImage(with: URL(string: thumbnail), placeholder: UIImage(named: "loading"))
            case 1:
                iv2.kf.setImage(with: URL(string: thumbnail), placeholder: UIImage(named: "loading"))
            case 2:
                iv3.kf.setImage(with: URL(string: thumbnail), placeholder: UIImage(named: "loading"))
            default:
                break
            }
        }
        bar.set(news: n)
    }
}


class NewsBar: UIView {
    let soucreName = UILabel()
    /// 阅读量
    let pvLabel = UILabel()
    let praiseNum = IUButton()
    let commentNum = IUButton(false)
    let publishTime = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        soucreName.font = UIFont.systemFont(ofSize: 12)
        soucreName.textColor = UIColor(0x666666)
        addSubview(soucreName)
        soucreName.snp.makeConstraints { maker in
            maker.left.top.bottom.equalTo(0)
        }
        
        publishTime.font = UIFont.systemFont(ofSize: 12)
        publishTime.textColor = UIColor(0x666666)
        addSubview(publishTime)
        publishTime.snp.makeConstraints { maker in
            maker.right.top.bottom.equalTo(0)
        }
        
        commentNum.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        commentNum.setTitleColor(UIColor(0x666666), for: .normal)
        commentNum.isUserInteractionEnabled = false
        addSubview(commentNum)
        commentNum.snp.makeConstraints { maker in
            maker.top.bottom.equalTo(0)
            maker.right.equalTo(publishTime.snp.left).offset(-15)
        }
        
        praiseNum.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        praiseNum.setTitleColor(UIColor(0x666666), for: .normal)
        praiseNum.isUserInteractionEnabled = false
        addSubview(praiseNum)
        praiseNum.snp.makeConstraints { maker in
            maker.top.bottom.equalTo(0)
            maker.right.equalTo(commentNum.snp.left).offset(-15)
        }
        
        pvLabel.font = UIFont.systemFont(ofSize: 12)
        pvLabel.textColor = UIColor(0x666666)
        addSubview(pvLabel)
        pvLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
            make.right.equalTo(praiseNum.snp.left).offset(-15)
        }
    }
    
    func set(news n: CarNews) {
        soucreName.text = n.sourceName
        pvLabel.text = "阅读量 \(n.pvNum?.max9999String ?? "0")"
        praiseNum.setTitle("\(n.praiseNum?.max9999String ?? "0") 赞", for: .normal)
        commentNum.setTitle("评论 \(n.commentNum?.max9999String ?? "0")", for: .normal)
        publishTime.text = n.publishTimeBO?.carnewsTimeString()
    }
}
