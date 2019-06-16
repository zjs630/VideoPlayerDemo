//
//  AppDelegate.swift
//  VideoPlayerDemo
//
//  Created by 张京顺 on 2019/6/16.
//  Copyright © 2019 ix86. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupAppearance()
        makeKeyAndVisible()
        
        return true
    }
    
}


extension AppDelegate {
    private func makeKeyAndVisible() {
        let carnews = CNListVideoViewController()
        let nav = UINavigationController(rootViewController: carnews)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }
    
    private func setupAppearance() {
        
        let tableView = UITableView.appearance()
        tableView.showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        
        let naviBar = UINavigationBar.appearance()
        naviBar.setBackgroundImage(UIImage(), for: .default)
        naviBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(0x222222), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
        naviBar.isTranslucent = false
        naviBar.shadowImage = UIImage(UIColor.mainLine, size: CGSize(width: .screenWidth, height: 1))
    }
    
}
