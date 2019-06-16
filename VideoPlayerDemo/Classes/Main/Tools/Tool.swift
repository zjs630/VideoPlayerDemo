//
//  Tool.swift
//  YHCar
//
//  Created by 李志兴 on 2017/4/17.
//  Copyright © 2017年 一号车市. All rights reserved.
//

import Foundation
import SwiftyJSON

class Tool {
    // MARK: - 提示框

    class func showAlert(_ msg: String = "", vc: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) {
        let ac = UIAlertController(title: "提示", message: msg, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "确定", style: UIAlertAction.Style.default, handler: nil)
        ac.addAction(okAction)
        vc?.present(ac, animated: true, completion: nil)
    }

}

// MARK: - 方法

func Log<T>(_ any: T..., fileName: String = #file, methodName: String = #function, lineNumber: Int = #line) {
    if isDeveloping {
        let str: String = (fileName as NSString).pathComponents.last!.replacingOccurrences(of: "swift", with: "")
        print("\(str)\(methodName)[\(lineNumber)]:\(any)")
    }
}

/// 开发阶段
///
/// - Returns: 是否是开发阶段
var isDeveloping: Bool {
    #if DEBUG || TEST || PREPRODUCT
        return true
    #else
        return false
    #endif
}

/// 是否是iPhoneX
var isIphoneX: Bool {
    return CGFloat.screenHeight == 812
}
