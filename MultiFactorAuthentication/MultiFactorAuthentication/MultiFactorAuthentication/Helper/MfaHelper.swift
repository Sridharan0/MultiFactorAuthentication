//
//  MfaHelper.swift
//  
//
//  Created by sridharan R on 05/09/22.
//

import Foundation
import UIKit
import BackgroundTasks

public class MfaHelper {
    
    /// Initialise all mfa sdk features.
    ///
    /// Call in AppDelegate
    ///
    ///        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    ///             MfaHelper.onAppLaunchInitialise()
    ///        }
    public class func onAppLaunchInitialise(launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil){
        print("😍On App Launched")
        PushNotification.sharedInstance.registerForPushNotifications()
        PushNotification.sharedInstance.setActionCategories()
        MfaHelper.registerBackgroundProcess()
        InitialConfiguration.sharedInstance.userId = UserDefaultsHelper.getData(type: String.self, forKey: .userId) ?? ""
        ApiHelper.shared.setAccessToken(accessToken: UserDefaultsHelper.getData(type: String.self, forKey: .accessToken) ?? "")
        if UserDefaultsHelper.getData(type: Bool.self, forKey: .isLocationServiceOn) == true {
            //hit locations
            OfflineManager.uploadLocalLocations()
            CoreLocationService.sharedInstance.startLocationChanges()
        }
    }
    
    /// Features that need to be run when app terminated.
    ///
    /// Call in AppDelegate
    ///
    ///         func applicationWillTerminate(_ application: UIApplication) {
    ///             MfaHelper.onAppTerminates()
    ///         }
    public class func onAppTerminates(){
        print("😭On App terminated")
        if UserDefaultsHelper.getData(type: Bool.self, forKey: .isLocationServiceOn) == true {
            CoreLocationService.sharedInstance.startSignificantLocationChanges()
        }
        CoreDataManager.shared.save()
    }
    
    /// Features that need to be run when app enters background.
    ///
    /// - Note - Call in `AppDelegate` if there is no `SceneDelegate`
    ///
    ///         func applicationDidEnterBackground(_ application: UIApplication) {
    ///            MfaHelper.onAppEnterBackground()
    ///         }
    ///
    ///         func sceneDidEnterBackground(_ scene: UIScene) {
    ///            MfaHelper.onAppEnterBackground()
    ///         }
    public class func onAppEnterBackground(){
        print("🤫App did enter background")
        if UserDefaultsHelper.getData(type: Bool.self, forKey: .isLocationServiceOn) == true {
            MfaHelper.scheduleBackgroundProcessing()
        }
    }
    
    //MARK: background update
    /// Register Background scheduler
    class func registerBackgroundProcess() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "net.routee.refreshUpdate", using: nil){ task in
            print("😍Background process started")
            //
            OfflineManager.uploadLocalLocations(){ success in
                task.setTaskCompleted(success: success) //when completed task
            }
            if UserDefaultsHelper.getData(type: Bool.self, forKey: .isLocationServiceOn) == true {
                MfaHelper.scheduleBackgroundProcessing()
            }
        }
    }
    
    /// Schedule Background Processing task
    /// - Parameter time: time interval for schedule
    class func scheduleBackgroundProcessing(time : Double = 30) {
        let request = BGProcessingTaskRequest(identifier: "net.routee.refreshUpdate")
        request.requiresNetworkConnectivity = true
        request.earliestBeginDate = Date(timeIntervalSinceNow: time * 60) //30 min
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    /// Check for location service state
    /// - Returns: true if location service is on.
    public class func isLocationPermissionActive() -> Bool {
        return UserDefaultsHelper.getData(type: Bool.self, forKey: .isLocationServiceOn) ?? false
    }
    
    static func showOkAlert(_ title : String = "Alert", message : String,_ actionTitle: String = "Ok", _ handler : ((UIAlertAction) -> ())? = nil, isShowCancel : Bool = false){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: handler))
        if isShowCancel {
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        }
        DispatchQueue.main.async{
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?.present(
                alert, animated: true, completion: nil)
        }
    }
    
    ///Get user details value
    public static func getUserDefault<T>(type: T.Type, key : UserDefaultKeys) -> T? {
        return UserDefaultsHelper.getData(type: type, forKey: key)
    }
    
    ///Get User Details
    public static func getUserDetails() -> String? {
        return UserDefaultsHelper.getData(type: String.self, forKey: .userId)
    }
    
    public static func logout() {
        UserDefaultsHelper.clearAllData()
        InitialConfiguration.sharedInstance.userId = ""
        ApiHelper.shared.setAccessToken(accessToken: "")
    }
        
    //MARK: Test codes
    
    /// Present popup to show copy option
    /// - Note: Testing purpose
    /// - Parameter title: title of alert
    /// - Parameter text: message content to copy
    public class func showCopyAlert(_ title: String? = nil, text : String){
        let alert = UIAlertController(title: "\(title ?? "Alert")",message: "\(text)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(
            title: "Copy",
            style: .default,
            handler: { _ in
                let pasteboard = UIPasteboard.general
                pasteboard.string = "\(text)"
            }
        ))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        DispatchQueue.main.async {
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?.present(
                            alert, animated: true, completion: nil)
        }
    }
    
    public static let isTestPushApp = Bundle.main.bundleIdentifier == "net.routee.testpush"
    
}


///
///
///


import UIKit
//import PureLayout

let ACTIVITY = Activity()

class Activity: NSObject {

    var window: UIWindow! = nil
    var backgroundView: UIView! = nil
    var currentDisplayedText: String! = nil

    // activity3
    private let doubleBounce1View = UIView()
    private let doubleBounce2View = UIView()

    // activity4
    private let spaceBetweenRect: CGFloat = 5.0
    private let rectCount = 5

    func show() {

        if window != nil {
            remove()
        }

        let w = UIWindow(frame: UIScreen.main.bounds)
        w.windowLevel = UIWindow.Level.normal + 1
        window = w

        let controller = UIViewController()
        controller.view.isUserInteractionEnabled = true
        controller.view.backgroundColor = UIColor(displayP3Red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        controller.view.isUserInteractionEnabled = true

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapRecognizer.numberOfTapsRequired = 3
        controller.view.addGestureRecognizer(tapRecognizer)

        backgroundView = UIView()

        activity4()

        controller.view.addSubview(backgroundView)

//        backgroundView.autoCenterInSuperview()
//        backgroundView.autoSetDimension(.width, toSize: UIScreen.main.bounds.size.width)
//        backgroundView.autoSetDimension(.height, toSize: UIScreen.main.bounds.size.height)

        window.rootViewController = controller
        window.makeKeyAndVisible()
    }

    func showWithText(text: String) {

        if self.currentDisplayedText != nil && window != nil {

            if self.currentDisplayedText == text {

                return
            }
        }

        if window != nil {
            remove()
        }

        self.currentDisplayedText = text

        let w = UIWindow(frame: UIScreen.main.bounds)
        w.windowLevel = UIWindow.Level.normal + 1
        window = w

        let controller = UIViewController()
        controller.view.isUserInteractionEnabled = true
        controller.view.backgroundColor = UIColor(displayP3Red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        controller.view.isUserInteractionEnabled = true

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapRecognizer.numberOfTapsRequired = 3
        controller.view.addGestureRecognizer(tapRecognizer)

        backgroundView = UIView()

        activity4()

        controller.view.addSubview(backgroundView)

//        backgroundView.autoCenterInSuperview()
//        backgroundView.autoSetDimension(.width, toSize: UIScreen.main.bounds.size.width)
//        backgroundView.autoSetDimension(.height, toSize: UIScreen.main.bounds.size.height)

        let label: UILabel = UILabel()
        label.textColor = UIColor.white
        label.text = text
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.textAlignment = NSTextAlignment.center
        backgroundView.addSubview(label)

//        label.autoPinEdge(.top, to: .top, of: backgroundView)
//        label.autoPinEdge(.left, to:.left, of: backgroundView)
//        label.autoPinEdge(ALEdge.right, to: ALEdge.right, of: backgroundView)
//           label.autoSetDimension(.height, toSize: UIScreen.main.bounds.size.height - 100)
        window.rootViewController = controller
        window.makeKeyAndVisible()
    }

    @objc func handleTap() {
        ACTIVITY.remove()
    }

    func remove() {
        if window != nil {
            window.isHidden = true
            self.currentDisplayedText = nil
            window = nil
        }
    }

    func activity5() {

        let beginTime = CACurrentMediaTime() + 2;
        let rectWidth: CGFloat = 20.0
        for index in 0 ..< rectCount {
            let layer = CALayer()
            layer.transform = CATransform3DMakeScale(1.0, 0.4, 0.0);
            
            let value = (ACTIVITY.window.bounds.size.width - rectWidth * (CGFloat(rectCount)) - spaceBetweenRect * (CGFloat(rectCount) / 2.0))
            let xPosition:CGFloat  =  value / 2.0 + CGFloat(index) * (rectWidth * 1.65)
            let yPosition:CGFloat = ACTIVITY.window.bounds.size.height / 2.0
            
            layer.frame = CGRect(x:xPosition, y: yPosition, width:rectWidth, height:rectWidth)
            
            layer.backgroundColor = UIColor.white.cgColor
            layer.cornerRadius = rectWidth / 2
            backgroundView.layer.addSublayer(layer)
        }

        for index in 0 ..< rectCount {
            let circleLayer = backgroundView.layer.sublayers![index]
            let aniScale = CAKeyframeAnimation()
            aniScale.keyPath = "transform.scale"
            aniScale.values = [1.0, 1.7, 1.0, 1.0]
            aniScale.isRemovedOnCompletion = false
            aniScale.repeatCount = HUGE
            aniScale.beginTime = beginTime - 2 + CFTimeInterval(index) * 0.2;
            aniScale.keyTimes = [0.0, 0.2, 0.4, 1.0];
            aniScale.timingFunctions = [
                CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            ]
            aniScale.duration = 2
            circleLayer.add(aniScale, forKey: "DTIAnimSpotify~scale")
        }
    }

    func activity4() {

        let beginTime = CACurrentMediaTime() + 2;
        let rectWidth: CGFloat = 15.0

        for index in 0 ..< rectCount {
            let layer = CALayer()
            layer.transform = CATransform3DMakeScale(1.0, 0.4, 0.0);
            layer.frame = CGRect(x: (ACTIVITY.window.bounds.size.width - rectWidth * (CGFloat(rectCount) / 2.0) - spaceBetweenRect * (CGFloat(rectCount) / 2.0)) / 2 + CGFloat(index) * (rectWidth + spaceBetweenRect) - rectWidth, y: ACTIVITY.window.bounds.size.height / 2, width: rectWidth, height: rectWidth * 4.0)
            layer.backgroundColor = UIColor.white.cgColor
            backgroundView.layer.addSublayer(layer)
        }

        for index in 0 ..< rectCount {

            let rectLayer = backgroundView.layer.sublayers![index]

            let aniScale = CAKeyframeAnimation()
            aniScale.keyPath = "transform"
            aniScale.isRemovedOnCompletion = false
            aniScale.repeatCount = HUGE
            aniScale.duration = 2
            aniScale.beginTime = beginTime - 2.0 + CFTimeInterval(index) * 0.1;
            aniScale.keyTimes = [0.0, 0.2, 0.4, 1.0];

            aniScale.timingFunctions = [
                CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            ]

            aniScale.values = [
                NSValue(caTransform3D: CATransform3DMakeScale(1.0, 0.4, 0.0)),
                NSValue(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 0.0)),
                NSValue(caTransform3D: CATransform3DMakeScale(1.0, 0.4, 0.0)),
                NSValue(caTransform3D: CATransform3DMakeScale(1.0, 0.4, 0.0))
            ]

            rectLayer.add(aniScale, forKey: "DTIAnimWave~scale\(index)")
        }
    }

    func activity3() {

        self.doubleBounce1View.layer.opacity = 0.6;
        self.doubleBounce1View.layer.cornerRadius = 25
        self.doubleBounce1View.backgroundColor = UIColor.white
        backgroundView.addSubview(self.doubleBounce1View)

//        self.doubleBounce1View.autoCenterInSuperview()
//        self.doubleBounce1View.autoSetDimension(.width, toSize: 50)
//        self.doubleBounce1View.autoSetDimension(.height, toSize: 50)

        self.doubleBounce2View.layer.opacity = 0.6;
        self.doubleBounce2View.layer.cornerRadius = 25
        self.doubleBounce2View.backgroundColor = UIColor.white
        backgroundView.addSubview(self.doubleBounce2View)

//        self.doubleBounce2View.autoCenterInSuperview()
//        self.doubleBounce2View.autoSetDimension(.width, toSize: 50)
//        self.doubleBounce2View.autoSetDimension(.height, toSize: 50)

        let aniScale1 = CAKeyframeAnimation()
        aniScale1.keyPath = "transform.scale"
        aniScale1.values = [1, 0.2, 1]
        aniScale1.isRemovedOnCompletion = false
        aniScale1.repeatCount = HUGE
        aniScale1.timingFunctions = [
            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        ]

        aniScale1.duration = 2

        let aniScale2 = CAKeyframeAnimation()
        aniScale2.keyPath = "transform.scale"
        aniScale2.values = [0.2, 1, 0.2]
        aniScale2.isRemovedOnCompletion = false
        aniScale2.repeatCount = HUGE
        aniScale2.timingFunctions = [
            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
            CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        ]

        aniScale2.duration = 2

        self.doubleBounce1View.layer.add(aniScale1, forKey: "DTIAnimDoubleBounce~aniScale1")
        self.doubleBounce2View.layer.add(aniScale2, forKey: "DTIAnimDoubleBounce~aniScale2")
    }

    func activity2() {

        let r = CAReplicatorLayer()
        r.bounds = CGRect(x: 0, y: 0, width: 50, height: 50)
        r.position = ACTIVITY.window.center
        r.backgroundColor = UIColor.clear.cgColor
        backgroundView.layer.addSublayer(r)
        r.masksToBounds = true

        let bar = CALayer()
        bar.bounds = CGRect(x: 0, y: 50, width: 2, height: 100)
        bar.position = CGPoint(x:0, y:50)
        bar.backgroundColor = UIColor.white.cgColor
        r.addSublayer(bar)

        r.instanceCount = 4
        let angle = CGFloat(2 * Double.pi) / CGFloat(4)
        r.instanceTransform = CATransform3DMakeRotation(angle, 0, 0, 1.0)

        let animationGroup = CAAnimationGroup()

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.duration = 1
        rotationAnimation.repeatCount = Float.infinity
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = Double.pi / 2

        let scaleAnamation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnamation.duration = 1
        scaleAnamation.repeatCount = Float.infinity
        scaleAnamation.values = [1, 0.5 * sqrt(2.0), 1]

        animationGroup.duration = 1
        animationGroup.repeatCount = Float.infinity
        animationGroup.animations = [rotationAnimation, scaleAnamation]

        bar.add(animationGroup, forKey: nil)
    }

    func activity1() {

        let count: CGFloat = 10

        let replicatorLayer = CAReplicatorLayer()
        replicatorLayer.frame = CGRect(x:0, y:0, width:50, height:50)
        replicatorLayer.position = ACTIVITY.window.center

        // 2
        replicatorLayer.instanceCount = Int(count)
        replicatorLayer.instanceDelay = CFTimeInterval(1 / count)
        replicatorLayer.preservesDepth = false
        replicatorLayer.instanceColor = UIColor.white.cgColor

        // 3
        replicatorLayer.instanceRedOffset = -0.5
        replicatorLayer.instanceGreenOffset = 0.0
        replicatorLayer.instanceBlueOffset = -0.5
        replicatorLayer.instanceAlphaOffset = 1.0

        // 4
        let angle = Float(Double.pi * 2.0) / Float(count)
        replicatorLayer.instanceTransform = CATransform3DMakeRotation(CGFloat(angle), 0.0, 0.0, 1.0)
        backgroundView.layer.addSublayer(replicatorLayer)

        // 5
        let instanceLayer = CALayer()
        let layerWidth: CGFloat = 10.0
        let midX = 30 - layerWidth / 2.0
        instanceLayer.frame = CGRect(x: midX, y: 0.0, width: layerWidth, height: layerWidth * 1.0)
        instanceLayer.cornerRadius = layerWidth / 2.0
        instanceLayer.backgroundColor = UIColor.white.cgColor
        replicatorLayer.addSublayer(instanceLayer)

        // 6
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 1
        fadeAnimation.repeatCount = Float(Int.max)

        // 7
        instanceLayer.opacity = 0.0
        instanceLayer.add(fadeAnimation, forKey: "FadeAnimation")
    }

}
