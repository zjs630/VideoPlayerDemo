//
//  BadNetworkReloadable.swift
//  YHUser
//
//  Created by 掎角之势 on 2018/4/26.
//  Copyright © 2018年 一号车市. All rights reserved.
//

import Alamofire
import Foundation
protocol BadNetworkRetryable: class {
    var needRetry: Bool { get set }

    func beginListenNetwork(handle: @escaping (() -> Void))
}

let reachMgr = NetworkReachabilityManager(host: NetConfig.host)
extension BadNetworkRetryable {
    func beginListenNetwork(handle: @escaping (() -> Void)) {
        if let reachMgr = reachMgr, reachMgr.startListening() {
            reachMgr.listener = { [weak self] status in
                Log(status)
                guard let this = self else { return }

                if this.needRetry, case .reachable = status {
                    handle()
                }
            }
        }
    }
}
