//
//  UIViewControler+Extension.swift
//  YHUser
//
//  Created by 掎角之势 on 2017/11/24.
//  Copyright © 2017年 一号车市. All rights reserved.
//

import Foundation
import UIKit

// MARK: - 统一设置一些公共特性

extension UIViewController: UIGestureRecognizerDelegate {
    /// 设置导航栏右按钮
    ///
    /// - Parameters:
    ///   - target: 点击事件调用者
    ///   - selector: 点击事件
    ///   - image: 图标
    ///   - title: 标题
    func setNaviRight(_ target: Any, selector: Selector, image: String? = nil, title: String? = nil) {
        let rightBtn = naviBtn(target, selector: selector, image: image, title: title)
        rightBtn.addTarget(target, action: selector, for: .touchUpInside)
        rightBtn.contentHorizontalAlignment = .right
        //        rightBtn.backgroundColor = UIColor.red
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
    }

    /// 设置导航栏左按钮
    ///
    /// - Parameters:
    ///   - target: 事件调用者
    ///   - selector: 点击事件
    ///   - image: 图标
    func setNaviLeft(_ target: Any?, selector: Selector = #selector(dismissVc), image: String? = nil, title: String? = nil) {
        guard let target = target else {
            navigationItem.leftBarButtonItem = nil
            return
        }
        let leftBtn = naviBtn(target, selector: selector, image: image, title: title)
        leftBtn.contentHorizontalAlignment = .left
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
    }

    @objc func dismissVc() {
        guard let count = navigationController?.children.count, count > 1 else {
            dismiss(animated: true, completion: nil)
            return
        }
        navigationController?.popViewController(animated: true)
    }

    private func naviBtn(_ target: Any?, selector: Selector = #selector(dismissVc), image: String? = nil, title: String? = nil) -> UIButton {
        let naviBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        if let title = title {
            naviBtn.setTitle(title, for: .normal)
            naviBtn.setTitleColor(UIColor(0x222222), for: .normal)
            naviBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            naviBtn.sizeToFit()
            naviBtn.width += 10
        }
        if let image = image {
            naviBtn.setImage(UIImage(named: image), for: .normal)
        }

        naviBtn.addTarget(target, action: selector, for: .touchUpInside)
        return naviBtn
    }
}
