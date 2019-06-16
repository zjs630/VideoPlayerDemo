//
//  YHPlayerTools.swift
//  VideoPlayerDemo
//
//  Created by ZhangJingshun on 2018/5/24.
//  Copyright © 2018年 一号车市. All rights reserved.
//

import UIKit

func printLog<T>(_ message: T, file: String = #file, funcName: String = #function, lineNum: Int = #line) {
    #if DEBUG
        let fileName: String = (file as NSString).lastPathComponent
        print("***********Log************\n🐶🐶【\(fileName)：\(lineNum),\(funcName)】->> \(message)")
    #endif
}

class YHPlayerTools {
    ///  get current top viewController
    ///
    /// - Returns: current top viewController
    static func activityViewController() -> UIViewController? {
        var result: UIViewController?
        guard var window = UIApplication.shared.keyWindow else {
            return nil
        }
        if window.windowLevel != UIWindow.Level.normal {
            let windows = UIApplication.shared.windows
            for tmpWin in windows {
                if tmpWin.windowLevel == UIWindow.Level.normal {
                    window = tmpWin
                    break
                }
            }
        }
        result = window.rootViewController
        while let presentedVC = result?.presentedViewController {
            result = presentedVC
        }
        if result is UITabBarController {
            result = (result as? UITabBarController)?.selectedViewController
        }
        while result is UINavigationController && (result as? UINavigationController)?.topViewController != nil {
            result = (result as? UINavigationController)?.topViewController
        }
        return result
    }

    /// get viewController from view
    ///
    /// - Parameter view: view
    /// - Returns: viewController
    static func viewController(from view: UIView) -> UIViewController? {
        var responder = view as UIResponder
        while let nextResponder = responder.next {
            if responder is UIViewController {
                return (responder as! UIViewController)
            }
            responder = nextResponder
        }
        return nil
    }
}
