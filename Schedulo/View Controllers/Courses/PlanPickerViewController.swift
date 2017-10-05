//
//  PlanPickerViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-10-04.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class PlanPickerViewController: UITableViewController {
    var stateController: StateController!
    var courseIndex: Int!

    var course: Course {
        return stateController.courses[courseIndex]
    }

    var selectedPlans = Set<Int>()

    lazy var cancelButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancel))
    lazy var addButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(self.add))

    override func viewDidLoad() {
        super.viewDidLoad()

        addButtonItem.isEnabled = false

        navigationItem.prompt = "Pick one or more plans to add \(course.name) to"
        navigationItem.leftBarButtonItem = cancelButtonItem
        navigationItem.rightBarButtonItem = addButtonItem
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stateController.plans.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)

        let plan = stateController.plans[indexPath.row]

        cell.textLabel?.text = "\(plan)"

        return cell
    }

    @objc private func cancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func add() {
        selectedPlans.forEach { planIndex in
            stateController.plans[planIndex].courses.append(course)
        }

        dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedPlans.contains(indexPath.row) {
            selectedPlans.remove(indexPath.row)
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            selectedPlans.insert(indexPath.row)
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }

        addButtonItem.isEnabled = !selectedPlans.isEmpty

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
