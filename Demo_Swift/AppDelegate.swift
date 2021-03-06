//
//  AppDelegate.swift
//  Demo_Swift
//
//  Created by pengquanhua on 2019/4/17.
//  Copyright © 2019 ifanr. All rights reserved.
//

import UIKit
import MinCloud
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        BaaS.register(clientID: "fdc4feb5403a98****") // 线上环境
        BaaS.registerWechat("wx4b3c1aff4c5****", universalLink: "https://xxxxx")
//        BaaS.register(clientID: "995140f59511a222*****") // qa测试环境
//        BaaS.register(clientID: "a4d2d62965ddb57****")  // 线上环境-支付
//        BaaS.register(clientID: "c981f1ec250e46e3****", serverURLString: "https://v5220.eng.szx.ifanrx.com")
        BaaS.registerWeibo("123456689", redirectURI: "https://open.weibo.com/wiki/Oauth2/authorize")
        BaaS.isDebug = true
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in

            // If granted comes true you can enabled features based on authorization.
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return BaaS.handleOpenURL(url: url)
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return BaaS.handleOpenURL(url: url)
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return BaaS.handleOpenURL(url: url)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return BaaS.handleOpenUniversalLink(userActivity: userActivity)
    }
}
