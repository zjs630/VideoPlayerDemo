//
//  CNDetailNormalViewController.swift
//  YHUser
//
//  Created by 掎角之势 on 2018/5/28.
//  Copyright © 2018年 一号车市. All rights reserved.
//

import UIKit
import WebKit
class CNDetailNormalViewController: WKWebViewController {
    var news: CarNews?
    private let h5pushNews = "pushNewsinfo"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupScriptMessageHandlers() {
        super.setupScriptMessageHandlers()

        scriptMessageHandlers["pushJsonString"] = { [weak self] message in

            if let jsonStr = message.body as? String, let data = jsonStr.data(using: .utf8) {
                if let info = ((try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]) as [String : Any]??) {
                    switch info?["action"] as? String ?? "" {
                    case "countOfPraiseAndComment":
                        let praiseNum = info?["countOfPraise"] as? Int ?? 0
                        let commentNum = info?["countOfComment"] as? Int ?? 0
                        self?.news?.commentNum = commentNum
                        self?.news?.praiseNum = praiseNum
                    default: break
                    }
                }
            }
        }
    }
}
