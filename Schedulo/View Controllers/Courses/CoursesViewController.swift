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

    override func viewDidLoad() {
        let addButtomItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCourse))

        navigationItem.title = "Courses"
        navigationItem.rightBarButtonItem = addButtomItem
        navigationItem.leftBarButtonItem = editButtonItem

        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    // MARK: - Private Methods

    // MARK: Course Management
    @objc private func addCourse() {
        let newCourse = Course("NEW101")

        stateController.courses.append(newCourse)

        let indexPath = IndexPath(row: stateController.courses.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    @objc private func longPressCourse(_ sender: UIGestureRecognizer) {
        guard sender.state == .began else {
            return
        }

        guard let cell = sender.view as? UITableViewCell else {
            return
        }

        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        let courseIndex = indexPath.row
        let course = stateController.courses[courseIndex]

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Add \(course.name) to a plan", style: .default, handler: { _ in
            let planPickerViewController = PlanPickerViewController()
            planPickerViewController.stateController = self.stateController
            planPickerViewController.courseIndex = courseIndex

            self.present(UINavigationController(rootViewController: planPickerViewController), animated: true, completion: nil)
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
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

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressCourse(_:)))
        cell.addGestureRecognizer(longPressRecognizer)

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
