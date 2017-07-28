//
//  SchedulesViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-14.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class PlansViewController: UITableViewController {
    // MARK: - Private Properties

    private let stateController: StateController

    // MARK: - Private Methods

    @objc private func addSchedule() {
        print("Adding schedule")
    }

    // MARK: - Initializers

    init(using stateController: StateController) {
        self.stateController = stateController

        super.init(style: .plain)

        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSchedule))

        self.navigationItem.title = "Schedules"
        self.navigationItem.rightBarButtonItem = addButtonItem

        if #available(iOS 11, *) {
            self.navigationItem.largeTitleDisplayMode = .always
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
