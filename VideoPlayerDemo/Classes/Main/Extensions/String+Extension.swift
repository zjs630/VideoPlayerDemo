//
//  String+Extension.swift
//  YHCar
//
//  Created by csb on 2017/5/23.
//  Copyright © 2017年 一号车市. All rights reserved.
//

import Foundation
import CoreGraphics

extension String {
    /// 去除字符串中 首、尾 的空格
    func wipeOffSpace() -> String {
        let whitespace = NSCharacterSet.whitespaces
        return trimmingCharacters(in: whitespace)
    }

    /// 去除字符串中 首、尾 的空格、换行符
    func wipeOffSpaceAndNewLine() -> String {
        let whitespace = NSCharacterSet.whitespacesAndNewlines
        return trimmingCharacters(in: whitespace)
    }

    /// 密文处理
    ///
    /// - Parameters:
    ///   - reservePre: 前面保留位数 - 默认值 = 3
    ///   - suf: 后面保留位数 - 默认值 = 4
    /// - Returns: 处理后的字符串
    func secret(reservePre pre: UInt = 3, suf: UInt = 4) -> String {
        if pre + suf <= count {
            let sIndex = index(startIndex, offsetBy: Int(pre))
            let length = count - Int(suf) - Int(pre)
            let eIndex = index(sIndex, offsetBy: length)

            return replacingCharacters(in: sIndex ..< eIndex, with: String(repeating: "＊", count: length))
        }
        return self
    }

    var isURLString: Bool {
        return check(validatedType: .url, validateString: self)
    }

    var isEmailString: Bool {
        return check(validatedType: .email, validateString: self)
    }

    var isPhoneString: Bool {
        return check(validatedType: .phone, validateString: self)
    }

    var isNikeNameString: Bool {
        return check(validatedType: .nikeName, validateString: self)
    }

    // MARK: - 检查号码,邮箱

    private enum PatternType: String {
        case email = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
        case phone = "^1[34578]\\d{9}$"
        case nikeName = "^[a-zA-Z\\d\\_\\-\\u2E80-\\u9FFF]{0,10}$"
        case url = "^(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]$"
    }

    private func check(validatedType type: PatternType, validateString: String) -> Bool {
        do {
            let pattern = type.rawValue
            let regex: NSRegularExpression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let matches = regex.matches(in: validateString, options: .reportProgress, range: NSMakeRange(0, validateString.count))
            return matches.count > 0

        } catch {
            return false
        }
    }

    /// 计算文字大小
    ///
    /// - Parameters:
    ///   - fontSize: 字体大小
    ///   - width: Label宽度
    ///   - height: 最大高度，默认值是1024
    /// - Returns: 文本大小
    func getStringSize(fontSize: CGFloat, width: CGFloat = 1024, height: CGFloat = 1024) -> CGSize {
        let statusLabelText = self as NSString
        let size = CGSize(width: width, height: height)
        let dic = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)]
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic, context: nil).size
        return strSize
    }
}
