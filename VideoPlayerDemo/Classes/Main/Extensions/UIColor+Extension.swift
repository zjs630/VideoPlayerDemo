//
//  UIColor+Extension.swift
//  YHUser
//
//  Created by 掎角之势 on 2017/6/27.
//  Copyright © 2017年 一号车市. All rights reserved.
//

import UIKit

// MARK: - 颜色

extension UIColor {
    convenience init(_ hex: Int, _ alpha: CGFloat = 1) {
        self.init(red: CGFloat(((hex & 0xFF0000) >> 16)) / 255.0, green: CGFloat(((hex & 0xFF00) >> 8)) / 255.0, blue: CGFloat((hex & 0xFF)) / 255.0, alpha: alpha)
    }

    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }

    func getRGB() -> (CGFloat, CGFloat, CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        return (red * 255, green * 255, blue * 255)
    }

    class var main: UIColor {
        return UIColor(0xFF9600)
    }

    class var lightMain: UIColor {
        return UIColor(0xFFB900)
    }

    class var mainBG: UIColor {
        return UIColor(0xF6F6F6)
    }

    class var mainLine: UIColor {
        return UIColor(0xECECEC)
    }
}
