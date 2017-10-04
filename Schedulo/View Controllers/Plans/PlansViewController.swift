//
//  SchedulesViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-14.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class PlansViewController: UITableViewController {
    var stateController: StateController!

    override func viewDidLoad() {
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPlan))

        self.navigationItem.title = "Plans"
        self.navigationItem.rightBarButtonItem = addButtonItem

        if #available(iOS 11, *) {
            self.navigationItem.largeTitleDisplayMode = .always
        }
    }

    // MARK: - Private Methods

    // MARK: Plan Management
    @objc private func addPlan() {
        let plan = Plan(for: .Fall, 2017)

        stateController.plans.append(plan)
        tableView.insertRows(at: [IndexPath(row: stateController.plans.count - 1, section: 0)], with: .automatic)
    }
}

// MARK: - UITableViewController Method Overrides
extension PlansViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stateController.plans.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = stateController.plans[indexPath.row].name

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if case .delete = editingStyle {
            stateController.plans.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let planDetailViewController = PlanDetailViewController(style: .grouped)
        planDetailViewController.stateController = stateController
        planDetailViewController.planIndex = indexPath.row

        navigationController?.pushViewController(planDetailViewController, animated: true)
    }
}
