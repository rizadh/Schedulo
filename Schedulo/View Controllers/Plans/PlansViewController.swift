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

    @objc private func addPlan() {
        print("Adding plan")

        var plan = Plan("TEST", in: .Fall, 2017)

        plan.courses = stateController.courses

        print(plan)

        stateController.add(plan)
    }

    // MARK: - Initializers

    init(using stateController: StateController) {
        self.stateController = stateController

        super.init(style: .plain)

        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPlan))

        self.navigationItem.title = "Plans"
        self.navigationItem.rightBarButtonItem = addButtonItem

        if #available(iOS 11, *) {
            self.navigationItem.largeTitleDisplayMode = .always
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewController Method Overrides
extension PlansViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stateController.plans.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        cell.textLabel?.text = stateController.plans[indexPath.row].name

        return cell
    }
}
