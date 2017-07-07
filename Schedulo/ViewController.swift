//
//  ViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-30.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class ViewController: UITabBarController {
    init() {
        super.init(nibName: nil, bundle: nil)
        
        let state = AppState()
        
        self.viewControllers = [UINavigationController (rootViewController: CoursesViewController(with: state))]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
