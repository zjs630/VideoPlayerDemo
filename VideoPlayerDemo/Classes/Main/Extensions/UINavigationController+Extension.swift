//
//  UINavigationController+Extension.swift
//  VideoPlayerDemo
//
//  Created by 张京顺 on 2019/6/16.
//  Copyright © 2019 ix86. All rights reserved.
//

import Foundation
extension UINavigationController {
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
