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
        let coursesViewController = CoursesViewController()
        coursesViewController.stateController = stateController

        let plansViewController = PlansViewController()
        plansViewController.stateController = stateController

        let navigationControllers = [
            UINavigationController(rootViewController: plansViewController),
            UINavigationController(rootViewController: coursesViewController)
        ]

        if #available(iOS 11, *) {
            navigationControllers.forEach { $0.navigationBar.prefersLargeTitles = true }
        }

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = navigationControllers
        tabBarController.selectedIndex = 1
        if #available(iOS 11.0, *) {
            tabBarController.tabBar.isSpringLoaded = true
        }

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = tabBarController

        return true
    }
}
