//
//  PlanSchedulesViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-10-04.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class PlanSchedulesViewController: UITableViewController {
    // MARK: State Management
    var stateController: StateController!
    var planIndex: Int!

    var schedules: [Schedule] {
        return stateController.plans[planIndex].schedules
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Schedules"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedules.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "Schedule \(indexPath.row + 1)"

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scheduleViewController = ScheduleViewController(style: .grouped)
        scheduleViewController.stateController = stateController
        scheduleViewController.planIndex = planIndex
        scheduleViewController.scheduleIndex = indexPath.row

        navigationController?.pushViewController(scheduleViewController, animated: true)
    }
}
