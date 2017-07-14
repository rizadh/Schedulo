//
//  SchedulesViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-14.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class SchedulesViewController: UITableViewController {
    // MARK: - Initializers

    init(using stateController: StateController) {
        super.init(style: .grouped)

        self.navigationItem.title = "Schedules"
        if #available(iOS 11, *) {
            self.navigationItem.largeTitleDisplayMode = .always
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
