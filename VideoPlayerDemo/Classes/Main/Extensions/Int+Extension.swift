//
//  Int+Extension.swift
//  YHUser
//
//  Created by 掎角之势 on 2017/11/15.
//  Copyright © 2017年 一号车市. All rights reserved.
//

import Foundation

extension Int {
    /// 格式化：最大99
    var max9999String: String {
        return self > 9999 ? "9999+" : "\(self)"
    }
}
