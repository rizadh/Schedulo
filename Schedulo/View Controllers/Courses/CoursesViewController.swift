//
//  CoursesViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-30.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class CoursesViewController: UITableViewController {
    // MARK: - Private Properties
    var stateController: StateController!

    override var title: String? {
        get {
            return "Courses"
        }

        set {}
    }

    var courses: [Course] {
        get {
            return stateController.courses
        }

        set {
            stateController.courses = newValue
        }
    }

    override func viewDidLoad() {
        let addButtomItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCourse))

        if #available(iOS 11.0, *) {
            tableView.dragDelegate = self
            tableView.dropDelegate = self
            tableView.dragInteractionEnabled = true
        }

        navigationItem.rightBarButtonItem = addButtomItem
        navigationItem.leftBarButtonItem = editButtonItem

        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if #available(iOS 11.0, *) {
            if !tableView.hasActiveDrag {
                tableView.reloadData()
            }
        } else {
            tableView.reloadData()
        }
    }

    // MARK: - Private Methods

    // MARK: Course Management
    @objc private func addCourse() {
        let newCourse = Course("NEW101")

        stateController.courses.append(newCourse)

        let indexPath = IndexPath(row: stateController.courses.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - UITableViewController Method Overrides

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stateController.courses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)

        let course = stateController.courses[indexPath.row]

        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = course.name

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let courseDetailViewController = CourseDetailViewController(style: .grouped)
        courseDetailViewController.stateController = stateController
        courseDetailViewController.courseIndex = indexPath.row

        navigationController?.pushViewController(courseDetailViewController, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if case .delete = editingStyle {
            stateController.courses.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceIndex = sourceIndexPath.row
        let destinationIndex = destinationIndexPath.row

        let movedCourse = stateController.courses.remove(at: sourceIndex)
        stateController.courses.insert(movedCourse, at: destinationIndex)
    }
}

@available(iOS 11, *)
extension CoursesViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let course = courses[indexPath.row]
        let courseProvider = CourseProvider(for: course)
        let itemProvider = NSItemProvider(object: courseProvider)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = course

        return [dragItem]
    }

    func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        let course = courses[indexPath.row]
        let courseProvider = CourseProvider(for: course)
        let itemProvider = NSItemProvider(object: courseProvider)
        let dragItem = UIDragItem(itemProvider: itemProvider)

        return [dragItem]
    }
}

@available(iOS 11, *)
extension CoursesViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: courses.count, section: 0)
        let destinationIndex = destinationIndexPath.row

        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                let sourceIndex = sourceIndexPath.row

                guard destinationIndex < courses.count else {
                    return
                }

                courses.swapAt(sourceIndex, destinationIndex)
                tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
                coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)
            } else if let course = item.dragItem.localObject as? Course {
                courses.insert(course, at: destinationIndexPath.row)
                tableView.insertRows(at: [destinationIndexPath], with: .automatic)
                coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)
            } else {
                let itemProvider = item.dragItem.itemProvider

                if itemProvider.canLoadObject(ofClass: CourseProvider.self) {
                    item.dragItem.itemProvider.loadObject(ofClass: CourseProvider.self) { (provider, _) in
                        let courseProvider = provider as! CourseProvider
                        let course = courseProvider.course

                        self.courses.insert(course, at: destinationIndex)

                        DispatchQueue.main.async {
                            tableView.insertRows(at: [destinationIndexPath], with: .automatic)
                        }
                    }

                    coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)
                }

                if itemProvider.canLoadObject(ofClass: PlanProvider.self) {
                    item.dragItem.itemProvider.loadObject(ofClass: PlanProvider.self, completionHandler: { (provider, _) in
                        let planProvider = provider as! PlanProvider
                        let plan = planProvider.plan
                        let courses = plan.courses

                        self.courses.insert(contentsOf: courses, at: destinationIndex)
                        let indexPaths = (0..<courses.count).map { IndexPath(row: destinationIndex + $0, section: 0) }

                        DispatchQueue.main.async {
                            tableView.insertRows(at: indexPaths, with: .automatic)
                        }
                    })

                    coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if tableView.hasActiveDrag {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }

    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: CourseProvider.self) || session.canLoadObjects(ofClass: PlanProvider.self)
    }
}
