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
    var planIndexEditing: Int?

    override var title: String? {
        get {
            return "Plans"
        }

        set { }
    }

    var plans: [Plan] {
        get {
            return stateController.plans
        }

        set {
            stateController.plans = newValue
        }
    }

    lazy var addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPlan))

    override func viewDidLoad() {
        if #available(iOS 11.0, *) {
            tableView.dropDelegate = self
            tableView.dragDelegate = self
            tableView.dragInteractionEnabled = true
        }

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

        if let index = planIndexEditing {
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        planIndexEditing = nil
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

        planIndexEditing = indexPath.row

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

    func tableView(_ tableView: UITableView, dragSessionWillBegin session: UIDragSession) {
        navigationItem.setLeftBarButton(nil, animated: true)
        navigationItem.setRightBarButton(nil, animated: true)

        tableView.allowsSelection = false
    }

    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
        navigationItem.setLeftBarButton(editButtonItem, animated: true)
        navigationItem.setRightBarButton(addButtonItem, animated: true)

        tableView.allowsSelection = true
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
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: plans.count, section: 0)
        let destinationIndex = destinationIndexPath.row

        for item in coordinator.items {
            let itemProvider = item.dragItem.itemProvider

            if let sourceIndexPath = item.sourceIndexPath {
                plans.swapAt(sourceIndexPath.row, destinationIndexPath.row)
                tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
            }

            if itemProvider.canLoadObject(ofClass: PlanProvider.self) {
                coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)

                itemProvider.loadObject(ofClass: PlanProvider.self, completionHandler: { (provider, _) in
                    let planProvider = provider as! PlanProvider
                    let plan = planProvider.plan

                    self.plans.insert(plan, at: destinationIndex)

                    tableView.insertRows(at: [destinationIndexPath], with: .automatic)
                })
            }

            if itemProvider.canLoadObject(ofClass: CourseProvider.self) {
                guard destinationIndex < plans.count
                    else { return }

                let cell = tableView.cellForRow(at: destinationIndexPath)!
                coordinator.drop(item.dragItem, intoRowAt: destinationIndexPath, rect: cell.bounds)

                item.dragItem.itemProvider.loadObject(ofClass: CourseProvider.self, completionHandler: { (provider, _) in
                    let courseProvider = provider as! CourseProvider
                    let course = courseProvider.course

                    self.plans[destinationIndex].courses.append(course)
                })
            }
        }
    }

    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: CourseProvider.self) || session.canLoadObjects(ofClass: PlanProvider.self)
    }
}
