//
//  PlanDetailViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-10-03.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class PlanDetailViewController: UITableViewController {
    // MARK: State Management
    var stateController: StateController!
    var planIndex: Int!

    private enum Cell {
        case year
        case season
    }

    private var cellEditing: Cell?

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

        title = "Plan"

        if #available(iOS 11, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let cell = cellEditing {
            switch cell {
            case .year:
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            case .season:
                tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            }

            cellEditing = nil
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.accessoryType = .disclosureIndicator

        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Year"
                cell.detailTextLabel?.text = "\(plan.year)"
            } else {
                cell.textLabel?.text = "Season"
                cell.detailTextLabel?.text = "\(plan.season)"
            }
        case 1:
            cell.textLabel?.text = "Manage Courses"
        case 2:
            cell.textLabel?.text = "Generated Schedules"
            cell.textLabel?.textColor = cell.tintColor
        default:
            break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let planYearViewController = PlanYearViewController()
                planYearViewController.stateController = stateController
                planYearViewController.planIndex = planIndex

                cellEditing = .year

                navigationController?.pushViewController(planYearViewController, animated: true)
            } else {
                let planSeasonViewController = PlanSeasonViewController()
                planSeasonViewController.stateController = stateController
                planSeasonViewController.planIndex = planIndex

                cellEditing = .season

                navigationController?.pushViewController(planSeasonViewController, animated: true)
            }
        case 1:
            let planCoursesViewController = PlanCoursesViewController(style: .grouped)
            planCoursesViewController.stateController = stateController
            planCoursesViewController.planIndex = planIndex

            navigationController?.pushViewController(planCoursesViewController, animated: true)
        case 2:
            let planSchedulesViewController = PlanSchedulesViewController()
            planSchedulesViewController.stateController = stateController
            planSchedulesViewController.planIndex = planIndex

            navigationController?.pushViewController(planSchedulesViewController, animated: true)
        default:
            break
        }
    }
}
