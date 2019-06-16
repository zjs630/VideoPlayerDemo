//
//  UIImage+Extension.swift
//  YHUser
//
//  Created by 掎角之势 on 2017/6/27.
//  Copyright © 2017年 一号车市. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    /// 创建纯色图片
    ///
    /// - Parameters:
    ///   - color: 颜色
    ///   - size: 大小
    convenience init(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        if let img = UIGraphicsGetImageFromCurrentImageContext() {
            self.init(cgImage: img.cgImage!)
        } else {
            self.init()
        }
        UIGraphicsEndImageContext()
    }

}
