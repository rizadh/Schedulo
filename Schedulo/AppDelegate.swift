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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let tabBarController = UITabBarController()

        let navigationControllers = [
            UINavigationController(rootViewController: PlansViewController(using: self.stateController)),
            UINavigationController(rootViewController: CoursesViewController(using: self.stateController))
        ]

        if #available(iOS 11, *) {
            navigationControllers.forEach { $0.navigationBar.prefersLargeTitles = true }
        }

        tabBarController.viewControllers = navigationControllers

        tabBarController.selectedIndex = 1

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = tabBarController

        return true
    }
}
