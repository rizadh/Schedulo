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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
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

                navigationController?.pushViewController(planYearViewController, animated: true)
            } else {
                let planSeasonViewController = PlanSeasonViewController()
                planSeasonViewController.stateController = stateController
                planSeasonViewController.planIndex = planIndex

                navigationController?.pushViewController(planSeasonViewController, animated: true)
            }
        default:
            break
        }
    }
}
