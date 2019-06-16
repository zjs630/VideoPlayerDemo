//
//  ErrorViewable.swift
//  YHUser
//
//  Created by 掎角之势 on 2017/9/5.
//  Copyright © 2017年 一号车市. All rights reserved.
//

import Foundation

protocol ErrorViewable: class {
//    var errorView: ErrorView { get set }
//
//    func setupErrorView(_ bgview: UIView?)

    func didCilicked(errorView: ErrorView)
}

// extension ErrorViewable where Self: UIViewController {
//
//    /// 集成无内容显示
//    func setupErrorView(_ bgview: UIView?) {
//
//        errorView.frame = view.bounds
//        errorView.delegate = self
//        errorView.displayType = .hidden
//
//
//        if let v = view {
//            v.addSubview(errorView)
//        } else {
//            view.addSubview(errorView)
//        }
//
//
//    }
//
// }
