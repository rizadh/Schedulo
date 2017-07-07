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
    private let stateController: StateController

    // MARK: - Initializers
    init(using stateController: StateController) {
        self.stateController = stateController

        super.init(style: .plain)

        self.navigationItem.title = "Courses"
        self.navigationItem.leftBarButtonItem = editButtonItem
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addCourse)),
            UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(self.presentUndoSheet))
        ]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Course Managing Methods
    @objc
    private func addCourse() {
        let controller = CourseDetailViewController(for: nil) { newCourse in
            self.stateController.add(newCourse)
            self.tableView.reloadData()
        }
        let navigationController = UINavigationController(rootViewController: controller)
        present(navigationController, animated: true, completion: nil)
    }

    @objc
    private func presentUndoSheet() {
        let controller = UIAlertController()
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if stateController.isFirstState {
            controller.title = "There is nothing to undo"
        } else {
            controller.title = "This cannot be reverted"
            controller.addAction(UIAlertAction(title: "Undo Last Change", style: .destructive, handler: { _ in
                self.stateController.revertState()
                self.tableView.reloadSections([0], with: .automatic)
            }))
        }
        present(controller, animated: true, completion: nil)
    }

    // MARK: - UITableViewController Overrides
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stateController.courses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = stateController.courses[indexPath.row].code
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let course = stateController.courses[index]
        let controller = CourseDetailViewController(for: course) { newCourse in
            self.stateController.replaceCourse(at: index, with: newCourse)
            self.tableView.reloadData()
        }
        let navigationController = UINavigationController(rootViewController: controller)
        present(navigationController, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            stateController.removeCourse(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            fatalError("Unsupported commit operation")
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
