//
//  BasicTableViewCell.swift
//  YHUser
//
//  Created by 掎角之势 on 2017/7/5.
//  Copyright © 2017年 一号车市. All rights reserved.
//

import UIKit

class BasicTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        selectionStyle = .none
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        subviews.filter({ "\($0.classForCoder)".hasSuffix("SeparatorView") }).forEach({
            $0.isHidden = self.selectionStyle != .none
            var frame = $0.frame
            frame.origin.x = self.separatorInset.left
            frame.size.width = .screenWidth - self.separatorInset.left - self.separatorInset.right
            $0.frame = frame
        })
    }
}
