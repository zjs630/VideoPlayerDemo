//
//  UIView+Extension.swift
//  YHUser
//
//  Created by 掎角之势 on 2017/6/27.
//  Copyright © 2017年 一号车市. All rights reserved.
//

import UIKit

// MARK: - xywh

extension UIView {
    var width: CGFloat {
        get {
            return frame.width
        }
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }

    var height: CGFloat {
        get {
            return frame.height
        }
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }

    var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }

    var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }

    var centerX: CGFloat {
        get {
            return center.x
        }
        set {
            var center = self.center
            center.x = newValue
            self.center = center
        }
    }

    var centerY: CGFloat {
        get {
            return center.y
        }
        set {
            var center = self.center
            center.y = newValue
            self.center = center
        }
    }

    var size: CGSize {
        get {
            return frame.size
        }
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }

}

extension UIView {
    func setViewLayer(cornerRadius: CGFloat = -1, borderColor: CGColor = UIColor.clear.cgColor, borderWidth: CGFloat = -1) {
        layer.masksToBounds = true
        if cornerRadius != -1 {
            layer.cornerRadius = cornerRadius
        }

        if borderWidth != -1 {
            layer.borderColor = borderColor
            layer.borderWidth = borderWidth
        }
    }

    func addRoundedCorners(withRect rect: CGRect, rectCorner: UIRectCorner, cornerRadii: CGSize) {
        let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: rectCorner, cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = rect
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}
