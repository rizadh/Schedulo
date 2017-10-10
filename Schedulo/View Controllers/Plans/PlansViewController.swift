//
//  SchedulesViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-14.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class PlansViewController: UITableViewController {
    var stateController: StateController!

    var plans: [Plan] {
        get {
            return stateController.plans
        }

        set {
            stateController.plans = newValue
        }
    }

    override func viewDidLoad() {
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPlan))

        if #available(iOS 11.0, *) {
            tableView.dropDelegate = self
            tableView.dragDelegate = self
            tableView.dragInteractionEnabled = true
        }

        navigationItem.title = "Plans"
        navigationItem.rightBarButtonItem = addButtonItem
        navigationItem.leftBarButtonItem = editButtonItem

        if #available(iOS 11, *) {
            navigationItem.largeTitleDisplayMode = .always
        }

        if #available(iOS 11.0, *) {
            tabBarItem.isSpringLoaded = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()

        if #available(iOS 11.0, *) {
            tableView.dropDelegate = self
        }
    }

    // MARK: - Private Methods

    // MARK: Plan Management
    @objc private func addPlan() {
        let plan = Plan(for: .Fall, 2017)

        stateController.plans.append(plan)
        tableView.insertRows(at: [IndexPath(row: stateController.plans.count - 1, section: 0)], with: .automatic)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stateController.plans.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

        let plan = stateController.plans[indexPath.row]

        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "\(plan)"

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if case .delete = editingStyle {
            stateController.plans.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let planDetailViewController = PlanDetailViewController(style: .grouped)
        planDetailViewController.stateController = stateController
        planDetailViewController.planIndex = indexPath.row

        navigationController?.pushViewController(planDetailViewController, animated: true)
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceIndex = sourceIndexPath.row
        let destinationIndex = destinationIndexPath.row

        let movedPlan = stateController.plans.remove(at: sourceIndex)
        stateController.plans.insert(movedPlan, at: destinationIndex)
    }
}

@available(iOS 11.0, *)
extension PlansViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let plan = plans[indexPath.row]
        let planProvider = PlanProvider(for: plan)
        let itemProvider = NSItemProvider(object: planProvider)
        let dragItem = UIDragItem(itemProvider: itemProvider)

        return [dragItem]
    }

    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        let plan = plans[indexPath.row]
        let planProvider = PlanProvider(for: plan)
        let itemProvider = NSItemProvider(object: planProvider)
        let dragItem = UIDragItem(itemProvider: itemProvider)

        return [dragItem]
    }
}

@available(iOS 11, *)
extension PlansViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if session.canLoadObjects(ofClass: PlanProvider.self) {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }

        if session.canLoadObjects(ofClass: CourseProvider.self) && destinationIndexPath != nil {
            return UITableViewDropProposal(operation: .copy, intent: .insertIntoDestinationIndexPath)
        }

        return UITableViewDropProposal(operation: .cancel)
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        if coordinator.session.canLoadObjects(ofClass: PlanProvider.self) {
            let destinationRow = coordinator.destinationIndexPath?.row ?? tableView.numberOfRows(inSection: 0)

            coordinator.session.loadObjects(ofClass: PlanProvider.self, completion: { (items) in
                let plansToInsert = (items as! [PlanProvider]).map { $0.plan }

                var indexPaths = [IndexPath]()
                for (index, plan) in plansToInsert.enumerated() {
                    self.plans.insert(plan, at: destinationRow + index)
                    indexPaths.append(IndexPath(row: destinationRow + index, section: 0))
                }

                DispatchQueue.main.async {
                    tableView.insertRows(at: indexPaths, with: .automatic)
                }
            })
        } else if coordinator.session.canLoadObjects(ofClass: CourseProvider.self) {
            let destinationRow = coordinator.destinationIndexPath!.row

            coordinator.session.loadObjects(ofClass: CourseProvider.self, completion: { (items) in
                let coursesToInsert = (items as! [CourseProvider]).map { $0.course }

                self.plans[destinationRow].courses.append(contentsOf: coursesToInsert)
            })
        }
    }

    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: CourseProvider.self) || session.canLoadObjects(ofClass: PlanProvider.self)
    }
}
