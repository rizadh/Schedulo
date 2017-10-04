//
//  SectionDetailViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-10-03.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class SectionDetailViewController: UITableViewController {
    // MARK: State Management
    var stateController: StateController!
    var courseIndex: Int!
    var sectionIndex: Int!

    private var section: Section {
        get {
            return stateController.courses[courseIndex].sections[sectionIndex]
        }

        set {
            stateController.courses[courseIndex].sections[sectionIndex] = newValue
        }
    }

    override func viewDidLoad() {
        title = "Section"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    // MARK: - UITableViewController Overrides
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.section.sessions.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)

        if indexPath.row == section.sessions.count {
            cell.textLabel?.textColor = cell.tintColor
            cell.textLabel?.text = "New Time"
        } else {
            let session = section.sessions[indexPath.row]

            cell.textLabel?.text = "\(session.day) \(session.time.start) - \(session.time.end)"
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Times"
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == section.sessions.count {
            let newSession = Session(day: .Monday, time: TimeRange(from: Time(hour: 9, minute: 0), to: Time(hour: 10, minute: 0)))
            section.sessions.append(newSession)

            let indexPath = IndexPath(row: section.sessions.count - 1, section: 0)

            tableView.deselectRow(at: indexPath, animated: true)
            tableView.insertRows(at: [indexPath], with: .automatic)
        } else {
            let sessionViewController  = SessionViewController(style: .grouped)
            sessionViewController.stateController = stateController
            sessionViewController.courseIndex = courseIndex
            sessionViewController.sectionIndex = sectionIndex
            sessionViewController.sessionIndex = indexPath.row

            navigationController?.pushViewController(sessionViewController, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        section.sessions.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 && indexPath.row < section.sessions.count
    }
}
