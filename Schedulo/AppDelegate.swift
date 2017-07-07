//
//  AppDelegate.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-23.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
   var stateController: StateController = StateController()

    lazy var coursesViewController: CoursesViewController = {
        CoursesViewController(using: self.stateController)
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        let rootViewController = UITabBarController()
        rootViewController.viewControllers = [
            UINavigationController(rootViewController: coursesViewController)
        ]
        window?.rootViewController = rootViewController

        return true
    }
}
