//
//  IUButton.swift
//  YHCar
//
//  Created by 李志兴 on 2017/4/25.
//  Copyright © 2017年 一号车市. All rights reserved.
//

import SnapKit
import UIKit
class IUButton: UIButton {
    fileprivate let line = UIView()

    var iu = true

    var indexPath = IndexPath(item: 0, section: 0)

    convenience init(_ showLine: Bool = false, iu: Bool = true) {
        self.init()
        titleLabel?.lineBreakMode = .byTruncatingTail
        self.iu = iu

        if showLine {
            line.backgroundColor = .mainBG
            addSubview(line)

            line.snp.makeConstraints({ maker in
                maker.top.equalToSuperview().offset(10)
                maker.bottom.equalToSuperview().offset(-10)
                maker.left.equalToSuperview()
                maker.width.equalTo(0.5)
            })
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let TitleW = titleLabel?.frame.width ?? 0
        let imageW = currentImage?.size.width ?? 0

        let margin: CGFloat = 2.5

        if iu {
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageW - margin, bottom: 0, right: imageW + margin)

            imageEdgeInsets = UIEdgeInsets(top: 0, left: TitleW + margin, bottom: 0, right: -TitleW - margin)

        } else {
            titleEdgeInsets = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: -margin)

            imageEdgeInsets = UIEdgeInsets(top: 0, left: -margin, bottom: 0, right: margin)
        }
    }
}
