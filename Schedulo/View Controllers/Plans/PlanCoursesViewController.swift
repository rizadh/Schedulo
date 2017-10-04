//
//  PlanCoursesViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-10-04.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class PlanCoursesViewController: UITableViewController {
    // MARK: State Management
    var stateController: StateController!
    var planIndex: Int!

    var plan: Plan {
        get {
            return stateController.plans[planIndex]
        }

        set {
            stateController.plans[planIndex] = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Courses"
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return plan.courses.count
        } else {
            return stateController.courses.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        if indexPath.section == 0 {
            cell.textLabel?.text = plan.courses[indexPath.row].name
            cell.selectionStyle = .none
        } else {
            cell.textLabel?.text = stateController.courses[indexPath.row].name
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Included (swipe to remove)"
        } else {
            return "Available (tap to include)"
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        plan.courses.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        plan.courses.append(stateController.courses[indexPath.row])
        tableView.insertRows(at: [IndexPath(row: plan.courses.count - 1, section: 0)], with: .automatic)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
