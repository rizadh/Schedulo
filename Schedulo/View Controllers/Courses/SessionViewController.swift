//
//  SessionViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-10-03.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class SessionViewController: UITableViewController {
    // MARK: State Management
    var stateController: StateController!
    var courseIndex: Int!
    var sectionIndex: Int!
    var sessionIndex: Int!

    var session: Session {
        get {
            return stateController.courses[courseIndex].sections[sectionIndex].sessions[sessionIndex]
        }

        set {
            stateController.courses[courseIndex].sections[sectionIndex].sessions[sessionIndex] = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Time"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadSections([0, 1, 2], with: .none)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)

        cell.accessoryType = .disclosureIndicator

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Day"
            cell.detailTextLabel?.text = "\(session.day)"
        case 1:
            cell.textLabel?.text = "Start"
            cell.detailTextLabel?.text = "\(session.time.start)"
        case 2:
            cell.textLabel?.text = "End"
            cell.detailTextLabel?.text = "\(session.time.end.description)"
        default:
            break
        }

        return cell
    }
}
