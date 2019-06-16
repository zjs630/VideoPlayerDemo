//
//  Double+DateFormater.swift
//  YHCar
//
//  Created by csb on 2017/5/9.
//  Copyright © 2017年 一号车市. All rights reserved.
//

import Foundation


private let formart = DateFormatter()

extension Double {
    static let secondsOneDay: Double = 60 * 60 * 24

    /// 动画时长
    static let animationDuration: Double = 0.25

    func carnewsTimeString() -> String {
        let thisTime = self / 1000
        let thisDate = Date(timeIntervalSince1970: thisTime)
        formart.dateFormat = "MM月dd日"
        return formart.string(from: thisDate)
    }

}
