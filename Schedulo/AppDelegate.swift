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
        let tabBarRects: [CGRect] = [
            CGRect(x: 10, y: 10, width: 14, height: 14),
            CGRect(x: 26, y: 10, width: 14, height: 14),
            CGRect(x: 10, y: 26, width: 14, height: 14),
            CGRect(x: 26, y: 26, width: 6, height: 6),
            CGRect(x: 34, y: 26, width: 6, height: 6),
            CGRect(x: 26, y: 34, width: 6, height: 6),
            CGRect(x: 34, y: 34, width: 2, height: 2),
            CGRect(x: 38, y: 34, width: 2, height: 2),
            CGRect(x: 34, y: 38, width: 2, height: 2),
            CGRect(x: 38, y: 38, width: 2, height: 2)
        ]

        let coursesViewController = CoursesViewController()
        coursesViewController.stateController = stateController
        if #available(iOS 10.0, *) {
            coursesViewController.tabBarItem.image = UIGraphicsImageRenderer(size: CGSize(width: 50, height: 50)) .image { context in
                for rect in tabBarRects {
                    context.fill(rect)
                }
            }
        }

        let plansViewController = PlansViewController()
        plansViewController.stateController = stateController
        if #available(iOS 10.0, *) {
            plansViewController.tabBarItem.image = UIGraphicsImageRenderer(size: CGSize(width: 50, height: 50)).image { context in
                for rect in tabBarRects {
                    context.cgContext.fillEllipse(in: rect)
                }
            }
        }

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
