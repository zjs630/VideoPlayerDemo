//
//  WKWebViewController.swift
//  YHCar
//
//  Created by 李志兴 on 2017/5/2.
//  Copyright © 2017年 一号车市. All rights reserved.
//

import Alamofire
import UIKit
import WebKit

class WKWebViewController: UIViewController, ErrorViewable {
    /// 是卖车页面 - 是的话需要直接返回原生
    var isSellCar = false

    var needRefresh: (() -> Void)?
    var isLoading = false
    private lazy var errorView: ErrorView = {
        let errorView = ErrorView()
        errorView.size = CGSize(width: .screenWidth, height: .screenHeight - 64)
        errorView.delegate = self
        errorView.displayType = .hidden
        return errorView

    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setNaviLeft(self, image: "navi_back")
        automaticallyAdjustsScrollViewInsets = false
        setupScriptMessageHandlers()

        path += "&timestamp=\(Date().timeIntervalSince1970)"
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            path += "&appVersion=\(version)"
        }

        errorView.height = .screenHeight - 64

        view.addSubview(webView)

        setupErrorView()

        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(doH5Reload), name: Notification.Name("payComplete"), object: nil)
        webViewReload()
        Log(path)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addAllScriptMessageHandler()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeAllScriptMessageHandler()
    }

    private func clearCache() {
        let set = WKWebsiteDataStore.allWebsiteDataTypes()
        let date = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: set, modifiedSince: date, completionHandler: {
            Log("清理完成！")
        })
    }

    var path = ""
    var requst: URLRequest?
    var orderID: String?
    var confirm = false
    var goFirstForward = false

    lazy var configur: WKWebViewConfiguration = {
        let configur = WKWebViewConfiguration()
        configur.allowsInlineMediaPlayback = true // 取消iPhone默认的视频全屏播放
        configur.userContentController = WKUserContentController()
        return configur
    }()

    lazy var webView: WKWebView = {
        let wv = WKWebView(frame: CGRect(x: 0, y: 0, width: .screenWidth, height: .screenHeight - 64), configuration: configur)
        wv.scrollView.bounces = false
        wv.scrollView.delegate = self
        wv.navigationDelegate = self
        wv.uiDelegate = self
        return wv
    }()

    private func addAllScriptMessageHandler() {
        scriptMessageHandlers.keys.forEach {
            configur.userContentController.add(self, name: $0)
        }

    }

    private func removeAllScriptMessageHandler() {
        scriptMessageHandlers.keys.forEach {
            webView.configuration.userContentController.removeScriptMessageHandler(forName: $0)
        }
    }

    var setToken = false

    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        NotificationCenter.default.removeObserver(self)
        Log(#function)
    }

    var scriptMessageHandlers = [String: ((WKScriptMessage) -> Void)]()
    func setupScriptMessageHandlers() {
        scriptMessageHandlers["dismiss"] = { [weak self] _ in
            self?.removeAllScriptMessageHandler()
            Log(Thread.current)
            self?.dismissVc()
        }

        scriptMessageHandlers["callPhone"] = { message in
            if let tel = message.body as? String, let url = URL(string: "telprompt://" + tel) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        }

        scriptMessageHandlers["setupRightBtn"] = { [weak self] message in
            if let par = message.body as? String {
                Log(par)
                self?.setupRightBtn(par)
            }
        }

        scriptMessageHandlers["showRightBtnTitle"] = { [weak self] message in
            if let par = message.body as? String {
                Log(par)
                self?.setupRightBtn(par)
            }
        }

        scriptMessageHandlers["needGoFirst"] = { [weak self] message in
            if let bool = message.body as? String {
                self?.goFirstForward = Bool(bool) ?? false
            }
        }

        scriptMessageHandlers["setupTitle"] = { [weak self] message in
            if let title = message.body as? String {
                self?.navigationItem.title = title
            }
        }

        scriptMessageHandlers["needRefreshList"] = { [weak self] _ in
            if self?.needRefresh != nil {
                self?.needRefresh?()
            }
        }


        scriptMessageHandlers["pushvc"] = { [weak self] message in
            let web = WKWebViewController()
            let price = "?vehicle_id=" + (message.body as? String ?? "")
            web.path = NetConfig.host_h5 + NetConfig.Url.details + price
            web.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(web, animated: true)
        }


        scriptMessageHandlers["getToken"] = { [weak self] _ in
            self?.setCommonable()
        }

        scriptMessageHandlers["pushCarInfo"] = { [weak self] message in
            guard let `self` = self else { return }
            if let info = message.body as? String, info != "" {
                Log(info)
                var shareIMGUrl = ""
                for (i, s) in info.components(separatedBy: "###").enumerated() {
                    switch i {
                    case 0:
                        self.shareUrl = s
                    case 1:
                        shareIMGUrl = s.components(separatedBy: "?").first ?? "" + "?x-oss-process=image/resize,m_fixed,h_100,w_100"
                    case 2:
                        self.shareTitle = s
                    case 3:
                        self.shareContent = s
                    case 4:
                        self.isShowCopyUrl = s == "true" ? true : false
                    default: break
                    }
                }
                // 定义NSURL
                if let imgURL = URL(string: shareIMGUrl) {
                    SessionManager.default.request(imgURL).responseData(completionHandler: { [weak self] response in
                        if let data = response.data, let image = UIImage(data: data) {
                            self?.shareImage = image
                        }
                    })
                }
                //self.setNaviRight(self, selector: #selector(self.showShare), image: "naviShare", title: nil)
            } else {
                self.navigationItem.rightBarButtonItem = nil
            }
        }

        scriptMessageHandlers["gotoSellCarPage"] = { [weak self] message in
            if let url = message.body as? String {
                self?.pushSellCarPage(NetConfig.host_h5 + url)
            }
        }

        scriptMessageHandlers["backToSellCar"] = { [weak self] message in
            if let bool = message.body as? String {
                self?.isSellCar = bool == "1"
            }
        }

        scriptMessageHandlers["gotoExternalBrowser"] = { _ in
            if let url = URL(string: "itms-apps://itunes.apple.com/cn/app/id1271307008?mt=8") {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        }



    }

    /// 分享的链接
    var shareUrl = ""
    /// 分享的标题
    var shareTitle = ""
    /// 分享的文案
    var shareContent = "我在一号车市看中了一辆车，帮我参谋下吧～"
    /// 分享弹窗是否显示复制URL
    var isShowCopyUrl = true
    /// 分享的图片
    var shareImage = UIImage()
    /// 分享的图片
    var shareImageUrl = ""
    /// 是否仅分享图片
    var isOnlyShareImage = false

    /// 网络重新连接时，是否需要刷新数据
    var needRetry: Bool {
        set {}
        get {
            return errorView.displayType == .web_failed
        }
    }
}

extension WKWebViewController: WKNavigationDelegate, UIScrollViewDelegate {
    func webView(_: WKWebView, didCommit _: WKNavigation!) {
        Log("")
    }

    func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//                Log(navigationAction.request.url)
        if let url = navigationAction.request.url {
            guard let scheme = url.scheme else {
                decisionHandler(.cancel)
                isLoading = false
                return
            }
            if scheme.hasSuffix("tel") {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                decisionHandler(.cancel)
                isLoading = false
                return
            }
            if scheme.hasPrefix("lewddriver") { // 屏蔽老司机网页自动跳转的bug add by zjs
                decisionHandler(.cancel)
                isLoading = false
                return
            }
        }
        decisionHandler(.allow)
    }

    func webView(_: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let respons = navigationResponse.response as? HTTPURLResponse {
            if respons.statusCode == 200 {
                decisionHandler(.allow)
            } else {
                errorView.displayType = .web_failed

                decisionHandler(.cancel)
                isLoading = false
            }
        } else {
            decisionHandler(.allow)
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of _: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        if (keyPath ?? "") != "estimatedProgress" {
            return
        }
    }

    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        Log("加载完成。。。")
        errorView.displayType = .hidden
        /// 是否一号车市域名，非一号车市的web，没有必要执行脚本
        var isYhcsDomain = webView.url?.absoluteString.contains("yhcs.com") ?? false
        #if DEBUG // 可能和某个固定ip联调
            isYhcsDomain = true
        #endif
        if isYhcsDomain {
            setCommonable()
            webView.evaluateJavaScript(String(format: "setParam('no')")) { _, _ in
                // Log(dic,error)
            }
        }
        isLoading = false
    }

    func webView(_: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError error: Error) {
        Log("加载失败。。。\(error)")
        if !isLoading && (error as NSError).code != -999 {
            errorView.displayType = .web_failed
        }

        isLoading = false
    }

    func didCilicked(errorView _: ErrorView) {
        webViewReload()
    }

    /// 集成无内容显示
    func setupErrorView() {
        view.addSubview(errorView)
    }

    private func webViewReload() {
        errorView.displayType = .hidden

        guard let url = URL(string: path.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "\"%<>@\\^`{|}").inverted)!) else {
            errorView.displayType = .web_failed

            return
        }
        var request = URLRequest(url: url)
//        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 15
        webView.load(request)
    }
}

extension WKWebViewController: WKUIDelegate {
    func webView(_: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame _: WKFrameInfo, completionHandler: @escaping () -> Void) {
        Tool.showAlert(message, vc: self)
        completionHandler()
    }
}

extension WKWebViewController: WKScriptMessageHandler {
    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        Log(message.name, message.body as? String)
        scriptMessageHandlers[message.name]?(message)
    }

    /// 跳转卖车页面
    func pushSellCarPage(_ url: String) {
        let web = WKWebViewController()
        web.title = "提交卖车信息"
        if url.contains("?") {
            web.path = url + "&" + "time=\(Date().timeIntervalSince1970)"
        } else {
            web.path = url + "?" + "time=\(Date().timeIntervalSince1970)"
        }

        web.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(web, animated: true)
    }

    private func setupRightBtn(_ title: String) {
        switch title {
        case "":
//            setRight(self, selector: #selector(rightBtnCilicked(_:)), image: "Image", title: nil)
            break
        case "nothing": navigationItem.rightBarButtonItem = nil
        default:
            setNaviRight(self, selector: #selector(rightBtnCilicked(_:)), image: nil, title: title)
        }
    }

    @objc private func rightBtnCilicked(_ sender: UIButton) {
        var jsStr = "rightEvent()"
        if let title = sender.currentTitle, !title.isEmpty {
            jsStr = "rightEvent(" + "\"" + title + "\"" + ")"
        }

        webView.evaluateJavaScript(jsStr, completionHandler: nil)
    }

    private func backForwad() {
        webView.evaluateJavaScript("backEvent()", completionHandler: { dic, error in
            Log(dic, error)
            if error != nil {
                self.dismissVc()
            }
        })
    }

    private func getShareInfo() {
        webView.evaluateJavaScript("notifyRetryShare()", completionHandler: { dic, error in
            Log(dic, error)
        })
    }

    override func dismissVc() {
        if isSellCar {
            super.dismissVc()
            return
        }

        if webView.canGoBack {
            if confirm {
                webView.evaluateJavaScript("backEvent()", completionHandler: { dic, error in
                    Log(dic, error)
                    if error != nil { self.confirm = false }
                })

                return
            }

            if goFirstForward {
                if let item = webView.backForwardList.backList.first {
                    webView.go(to: item)

                    goFirstForward = false
                }
                return
            }

            webView.goBack()
        } else {
            super.dismissVc()
        }
    }

    /// 设置用户信息：token，城市id，手机号
    private func setCommonable() {
//        let function = "setCommonable('\(User.shared.token ?? "")','\(City.shared.id)','\(User.shared.mobile ?? "")',\(TARGET_OS_SIMULATOR == 0),'\(UserDefaults.standard.value(forKey: "deviceToken") ?? "")','\(User.shared.customerId ?? 0)')"
//        webView.evaluateJavaScript(function) { dic, error in
//            Log(function)
//            Log(dic, error)
//        }
    }

    /// H5分享到朋友圈
    private func h5ShareLuck() {
//        showSharePlatforms(needCopy: isShowCopyUrl) { _, _ in
////            self?.tellH5(shareSuccess: error == nil)
//        }
    }

    /// 告知H5分享是否成功
    ///
    /// - Parameter shareSuccess: 成功：true，失败：false
    private func tellH5(shareSuccess: Bool) {
        let function = "activityShareResult(\(shareSuccess))"
        webView.evaluateJavaScript(function) { dic, error in
            Log(function)
            Log(dic, error)
        }
    }

    /// 告知H5是否是真机、deviceToken
    private func tellH5DeviceInfo() {
        let function = "setUserInfo(\(TARGET_OS_SIMULATOR),\(UserDefaults.standard.value(forKey: "deviceToken") ?? ""))"
        webView.evaluateJavaScript(function) { dic, error in
            Log(function)
            Log(dic, error)
        }
    }

    @objc private func doH5Reload() {
        webView.evaluateJavaScript(String(format: "reload();")) { dic, error in
            Log(dic, error)
        }
    }

    @objc func keyboardWillChange(_ noti: Notification) {
        if noti.name == UIResponder.keyboardWillShowNotification {
            if let rect = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                tellH5(keyboardHeight: rect.height)
            }

        } else if noti.name == UIResponder.keyboardWillHideNotification {
            tellH5(keyboardHeight: 0)
        }
    }

    private func tellH5(keyboardHeight height: CGFloat) {
        Log(height)
//        webView.evaluateJavaScript(String(format: "setKeyboardHeight('\(height)');")) { (dic, error) in
//            Log(dic,error)
//        }
    }
}

//extension WKWebViewController: Shareable {
//    @objc func showShare() {
//        isOnlyShareImage = false
//        showSharePlatforms(needCopy: isShowCopyUrl) { [weak self] _, error in
//            self?.tellH5(shareSuccess: error == nil)
//        }
//        MobClick.event(String.EventId.carPageShare)
//    }
//}

extension WKWebViewController: BadNetworkRetryable {}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value) })
}
