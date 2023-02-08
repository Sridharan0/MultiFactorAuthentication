//
//  VideoCallVC.swift
//  
//
//  Created by sridharan R on 20/10/22.
//

import Foundation
import UIKit
import WebKit
import SafariServices

class VideoCallVC : UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var webView : WKWebView!
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var acceptDenyView: UIStackView!
    @IBOutlet weak var denyButton: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var webViewToAcceptDenyViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var webViewToSafeAreaConstraint: NSLayoutConstraint!
    
    var roomLink = ""
    
    var completionHandler: ((Bool) -> ())? = nil
    
    private var isCorrectUrlLoaded = false
    
    var userInfoApns: UserInfoAPNS?
    
    //
    var v1 : UIView? = nil
    var v2 : UIView? = nil
    
    override func viewDidLoad(){
        super.viewDidLoad()
        configureWebView()
        
        webViewToAcceptDenyViewConstraint.priority = .defaultHigh
        webViewToSafeAreaConstraint.priority = .defaultLow
        if let userInfoApns = userInfoApns , UserInfoAPNS.VideoConferenceType.init(rawValue: userInfoApns.aps?.videoConferenceType ?? "") == .verifyAuth {
            actionBtn.isHidden = false
            denyButton.isHidden = false
            closeBtn.isHidden = true
            actionBtn.addCornorRadius()
            denyButton.addCornorRadius()
        }else{
            actionBtn.isHidden = true
            denyButton.isHidden = true
            closeBtn.isHidden = false
            closeBtn.addCornorRadius()
        }
        
        if let url = URL(string: roomLink) {
//            self.webView.load(URLRequest(url: url))
            self.showSafariVC(roomLink: url)
        } else {
            self.goAMDBack({ _ in
                self.completionHandler?(false)
                self.completionHandler = nil
            })
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.vcAuthApproved(notification:)), name: Notification.Name(APNsStatusUpdateIdentifier), object: nil)
    }
    
    @objc func vcAuthApproved(notification: Notification){
        let statusUserInfo : UserInfoAPNS? = notification.userInfo?[UserInfoApnsKey] as? UserInfoAPNS
        let success = statusUserInfo?.aps?.status?.uppercased() ?? "" == SUCCESS
        
        self.goAMDBack({ _ in
            self.completionHandler?(success)
            self.completionHandler = nil
        })
    }
    
    func configureWebView(){
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore =  WKWebsiteDataStore.nonPersistent()
        configuration.preferences = preferences
        
        let contentController = WKUserContentController()
        configuration.userContentController = contentController
        
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsInlineMediaPlayback = true
        //        configuration.mediaPlaybackRequiresUserAction = false
        webView.navigationDelegate = self
        webView.customUserAgent = "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.96 Safari/537.36"
    }
    
    func checkCurrentUrl(url: String, didFinish : Bool) {
        if url != roomLink {
            //Webview check url loaded.
            if !isCorrectUrlLoaded { //failed to load meet url
                self.showOKAlert(withTitle: "Alert", message: "Failed to load url", handler: { _ in
                    self.goAMDBack({ _ in
                        self.completionHandler?(false)
                        self.completionHandler = nil
                    })
                })
                return
            }
            //handle api call for verification check
            self.goAMDBack({ _ in
                self.completionHandler?(true)
                self.completionHandler = nil
            })
        }else if didFinish && !isCorrectUrlLoaded {
            isCorrectUrlLoaded = true
        }
    }
    
    
    //MARK: IBAction
    @IBAction func onAcceptAction(_ sender: Any) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [userInfoApns?.actionToken ?? ""])
        self.goAMDBack({ _ in
            self.completionHandler?(true)
            self.completionHandler = nil
        })
    }
    
    @IBAction func onDenyAction(_ sender: Any) {
        self.goAMDBack({ _ in
            self.completionHandler?(false)
            self.completionHandler = nil
        })
    }
    
    @IBAction func onCloseActon(_ sender : UIButton?){
        //handle api call for verification check
        self.goAMDBack({ _ in
            self.completionHandler?(false)
            self.completionHandler = nil
        })
    }
    
}

//MARK: WKUIDelegate
extension VideoCallVC : WKUIDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print(webView.url ?? "")
        if let url = webView.url?.absoluteString {
            if url == roomLink {
                showMfaLoader()
            }
            checkCurrentUrl(url: url, didFinish: false)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(webView.url ?? "")
        hideMfaLoader()
        if let url = webView.url?.absoluteString {
            checkCurrentUrl(url: url, didFinish: true)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(webView.url ?? "")
        hideMfaLoader()
        webView.goBack()
    }
}

//MARK: SFSafariViewControllerDelegate
extension VideoCallVC : SFSafariViewControllerDelegate {
    
    func showSafariVC(roomLink : URL) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let safariVC = SFSafariViewController(url: roomLink, configuration: config)
        safariVC.delegate = self
        //
        addChild(safariVC)

        self.view.addSubview(safariVC.view)

        safariVC.didMove(toParent: self)
        safariVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        AddViewToHideIcons()
        //set gap below safari view
        safariVC.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true

        safariVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -80).isActive = true

        safariVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true

        safariVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -0).isActive = true
        
        //present safari view controller
//        NavigationHelper.shared.openScreen(currentVc: self, nextVc: safariVC)
    }
    
    func safariViewControllerWillOpenInBrowser(_ controller: SFSafariViewController) {
        if controller.userActivity?.webpageURL?.absoluteString != roomLink{
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if controller.userActivity?.webpageURL?.absoluteString != roomLink{
            controller.dismiss(animated: true, completion: nil)
        }
        onCloseActon(nil)
    }
    
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        if URL.absoluteString != roomLink{
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        print("loaded")
    }
    
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        return [UIActivity()]
    }
}

//MARK: Orientation change
extension VideoCallVC {
    
    func AddViewToHideIcons(){
        v1?.removeFromSuperview()
        v2?.removeFromSuperview()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [self] in
            if UIDevice.current.orientation.isLandscape {
                v1 = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
                v1?.backgroundColor = UIColor.white
                if let v1 = v1 {
                    self.view.addSubview(v1)
                }
                print("Landscape")
            } else {
                print("Portrait")
                v1 = UIView(frame: CGRect(x: 0, y: view.safeAreaInsets.top, width: self.view.frame.width, height: 40))
                v2 = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 80 - 45  , width: self.view.frame.width, height: 45))
                v1?.backgroundColor = UIColor.white
                v2?.backgroundColor = UIColor.white
                if let v1 = v1 {
                    self.view.addSubview(v1)
                }
                if let v2 = v2 {
                    self.view.addSubview(v2)
                }
            }
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.AddViewToHideIcons()
    }
}
