//
//  CarNewsDataTool.swift
//  YHUser
//
//  Created by 掎角之势 on 2018/5/23.
//  Copyright © 2018年 一号车市. All rights reserved.
//

import SwiftyJSON
import UIKit
class CarNewsDataTool {

    // 获取资讯列表
    class func getListByTopic(_ parameters: [String: Any], _ finishedCallback: @escaping (_ result: JSON?) -> Void) {
        
        //let chanel: Int = Int(parameters["channel"] as! String) ?? 1
        let resource = "demo4.json"
        do {
            let urlStr = Bundle.main.path(forResource: resource, ofType: nil)!
            let data = try Data(contentsOf: URL(fileURLWithPath: urlStr))
            let result = try JSON(data: data)
            finishedCallback(result)
        } catch {
            print(error)
            finishedCallback(nil)
        }
        

    }
}
