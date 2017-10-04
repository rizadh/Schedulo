//
//  CourseDetailViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-10-03.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class CourseDetailViewController: UITableViewController {
    // MARK: State Management

    var stateController: StateController!
    var courseIndex: Int!

    // MARK: Course Management

    private var course: Course {
        get {
            return stateController.courses[courseIndex]
        }

        set {
            stateController.courses[courseIndex] = newValue
        }
    }

    // MARK: - UIViewController Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Edit Course"

        if #available(iOS 11, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadSections([0, 1], with: .none)
    }

    // MARK: - UITableViewController Overrides

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return course.sections.count + 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Name"
            cell.detailTextLabel?.text = course.name
            cell.accessoryType = .disclosureIndicator
        default:
            break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return "Sections"
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let courseNameViewController = CourseNameViewController(style: .grouped)
            courseNameViewController.stateController = stateController
            courseNameViewController.courseIndex = courseIndex

            navigationController?.pushViewController(courseNameViewController, animated: true)
        default:
            break
        }
    }
}
