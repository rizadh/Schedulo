//
//  ScheduleViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-10-04.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class ScheduleViewController: UITableViewController {
    // MARK: State Management
    var stateController: StateController!
    var planIndex: Int!
    var scheduleIndex: Int!

    var schedule: Schedule {
        return stateController.plans[planIndex].schedules[scheduleIndex]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Schedule"
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return schedule.selectedSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Array(schedule.selectedSections)[section].value.sessions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        let session = Array(schedule.selectedSections)[indexPath.section].value.sessions[indexPath.row]
        cell.textLabel?.text = "\(session.day) \(session.time.start) - \(session.time.end)"

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(schedule.selectedSections)[section].key.name
    }
}
