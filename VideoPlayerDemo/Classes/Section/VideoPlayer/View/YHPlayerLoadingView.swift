//
//  YHPlayerLoadingView.swift
//  VideoPlayerDemo
//
//  Created by ZhangJingshun on 2018/5/23.
//  Copyright © 2018年 一号车市. All rights reserved.
//

import UIKit

class YHPlayerLoadingView: UIView {
    private let duration = 1.2
    private var timer: Timer?
    private var radius: Double?

    private lazy var circle: CAShapeLayer = { [weak self] in
        let theCircle = CAShapeLayer()
        theCircle.fillColor = UIColor.clear.cgColor
        theCircle.strokeColor = UIColor.white.cgColor
        theCircle.lineWidth = 3
        theCircle.opacity = 0
        theCircle.strokeEnd = 0
        theCircle.strokeStart = 0
        self?.layer.addSublayer(theCircle)
        return theCircle
    }()

    // MARK: - Life cycle

    deinit {
        timer?.invalidate()
        timer = nil
        layer.removeAllAnimations()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        if radius == nil {
            radius = Double(frame.size.width) / 2.0
        }
        let bezierPath = UIBezierPath(ovalIn: CGRect(x: CGFloat(frame.size.width / 2.0 - CGFloat(radius! / 2.0)), y: CGFloat(frame.size.height / 2.0 - CGFloat(radius! / 2.0)), width: CGFloat(radius!), height: CGFloat(radius!)))
        circle.path = bezierPath.cgPath
    }

    // MARK: - Public methods

    open func start() {
        if timer != nil {
            return
        }

        timer?.invalidate()
        timer = nil

        circle.removeAllAnimations()
        addAnimate()

        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true) { [weak self] _ in
            self?.circle.removeAllAnimations()
            self?.addAnimate()
        }
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)

        isHidden = false
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
            self.circle.opacity = 1
            self.alpha = 1
        }, completion: nil)
    }

    open func stop() {
        if timer == nil {
            return
        }

        timer?.invalidate()
        timer = nil

        circle.removeAllAnimations()

        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            self?.circle.opacity = 0
            self?.alpha = 0
        }, completion: { [weak self] finished in
            if finished {
                self?.isHidden = true
            }
        })
    }

    // MARK: - Private methods

    private func commonInit() {
        isHidden = true
    }

    private func addAnimate() {
        let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
        endAnimation.fromValue = 0
        endAnimation.toValue = 1
        endAnimation.duration = duration
        endAnimation.isRemovedOnCompletion = true
        circle.add(endAnimation, forKey: "end")
        let startAnimation = CABasicAnimation(keyPath: "strokeStart")
        startAnimation.beginTime = CACurrentMediaTime() + duration / 2
        startAnimation.fromValue = 0
        startAnimation.toValue = 1
        startAnimation.isRemovedOnCompletion = true
        startAnimation.duration = duration / 2
        circle.add(startAnimation, forKey: "start")
    }
}
