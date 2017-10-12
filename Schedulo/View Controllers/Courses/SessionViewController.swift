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

    private enum Cell {
        case day
        case start
        case end
    }

    private var cellEditing: Cell?

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let cell = cellEditing {
            switch cell {
            case .day:
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            case .start:
                tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
            case .end:
                tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)
            }

            cellEditing = nil
        }
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let sessionDayViewController = SessionDayViewController()
            sessionDayViewController.stateController = stateController
            sessionDayViewController.courseIndex = courseIndex
            sessionDayViewController.sectionIndex = sectionIndex
            sessionDayViewController.sessionIndex = sessionIndex

            cellEditing = .day

            navigationController?.pushViewController(sessionDayViewController, animated: true)
        case 1:
            let sessionStartTimeViewController = SessionStartTimeViewController()
            sessionStartTimeViewController.stateController = stateController
            sessionStartTimeViewController.courseIndex = courseIndex
            sessionStartTimeViewController.sectionIndex = sectionIndex
            sessionStartTimeViewController.sessionIndex = sessionIndex

            cellEditing = .start

            navigationController?.pushViewController(sessionStartTimeViewController, animated: true)
        case 2:
            let sessionEndTimeViewController = SessionEndTimeViewController()
            sessionEndTimeViewController.stateController = stateController
            sessionEndTimeViewController.courseIndex = courseIndex
            sessionEndTimeViewController.sectionIndex = sectionIndex
            sessionEndTimeViewController.sessionIndex = sessionIndex

            cellEditing = .end

            navigationController?.pushViewController(sessionEndTimeViewController, animated: true)
        default:
            break
        }
    }
}
