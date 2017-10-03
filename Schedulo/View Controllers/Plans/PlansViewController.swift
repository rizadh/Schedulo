//
//  SchedulesViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-14.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class PlansViewController: UITableViewController {
    // MARK: - Private Properties

    private let stateController: StateController
    private var textFieldChangeHandler: TextFieldChangeHandler?

    // MARK: - Private Methods

    // MARK: Button Handlers
    @objc private func addButtonItemHandler() {
        addPlan()
    }

    // MARK: Plan Management
    private func addPlan() {
        var plan = Plan(for: .Fall, 2017)

        plan.courses = stateController.courses

        stateController.add(plan)
        tableView.insertRows(at: [IndexPath(row: stateController.plans.count - 1, section: 0)], with: .automatic)
    }

    private func editPlan(at index: Int) {

    }

    private func deletePlan(at index: Int) {
        stateController.removePlan(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    // MARK: - Initializers

    init(using stateController: StateController) {
        self.stateController = stateController

        super.init(style: .plain)

        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonItemHandler))

        self.navigationItem.title = "Plans"
        self.navigationItem.rightBarButtonItem = addButtonItem

        if #available(iOS 11, *) {
            self.navigationItem.largeTitleDisplayMode = .always
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewController Method Overrides
extension PlansViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stateController.plans.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = stateController.plans[indexPath.row].name

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if case .delete = editingStyle {
            deletePlan(at: indexPath.row)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editPlan(at: indexPath.row)
    }
}
