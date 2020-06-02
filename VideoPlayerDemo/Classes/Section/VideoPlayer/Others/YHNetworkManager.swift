//
//  YHNetworkManager.swift
//  YHUser
//
//  Created by ZhangJingshun on 2018/5/30.
//  Copyright © 2018年 一号车市. All rights reserved.
//

import Alamofire
import UIKit

class YHNetworkManager: NSObject {
    static let sharedInstance = YHNetworkManager()
    let network = NetworkReachabilityManager(host: "https://baidu.com")
    var isWifi: Bool = false
    var status: NetworkReachabilityManager.NetworkReachabilityStatus?
    override init() {
        super.init()

        let listener = { (status: NetworkReachabilityManager.NetworkReachabilityStatus)  in
            self.status = status
            switch status {
            case .notReachable, .unknown:
                break
            case let .reachable(type):
                self.isWifi = type == .ethernetOrWiFi ? true : false
                printLog(self.isWifi)
            }
        }

        if let net = network, net.startListening(onUpdatePerforming: listener) {
            isWifi = net.isReachableOnEthernetOrWiFi
            printLog(isWifi)

        }
    }
}
