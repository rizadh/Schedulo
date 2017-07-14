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
    private var addCourseItem: UIBarButtonItem!

    // MARK: - Initializers
    init(using stateController: StateController) {
        self.stateController = stateController

        super.init(style: .plain)

        addCourseItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addCourse))

        self.navigationItem.title = "Courses"
        self.navigationItem.rightBarButtonItem = addCourseItem
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .always
        }

        self.updateStateBasedViews()
        NotificationCenter.default.addObserver(forName: Notification.Name("stateDidChange"), object: nil, queue: nil) { [weak self] _ in
            self?.updateStateBasedViews()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods


    private func updateStateBasedViews() {
        if stateController.courses.isEmpty {
            self.navigationItem.setLeftBarButton(nil, animated: true)
        } else {
            self.navigationItem.setLeftBarButton(editButtonItem, animated: true)
        }
    }

    // MARK: Course Management
    @objc
    private func addCourse() {
        let courseIndex = self.stateController.courses.count
        let indexPath = IndexPath(row: courseIndex, section: 0)
        let courseDetailViewController = CourseDetailViewController(for: nil) {
            if courseIndex < self.stateController.courses.count {
                self.stateController.replaceCourse(at: courseIndex, with: $0)
                self.tableView.reloadRows(at: [indexPath], with: .none)
            } else {
                self.stateController.add($0)
                let indexPath = IndexPath(row: courseIndex, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .none)
            }

        }

        navigationController?.pushViewController(courseDetailViewController, animated: true)
    }

    private func editCourse(at courseIndex: Int) {
        let course = stateController.courses[courseIndex]
        let courseDetailViewController = CourseDetailViewController(for: course) {
            self.stateController.replaceCourse(at: courseIndex, with: $0)
            self.tableView.reloadRows(at: [IndexPath(row: courseIndex, section: 0)], with: .fade)
        }

        navigationController?.pushViewController(courseDetailViewController, animated: true)
    }

    private func deleteCourse(at courseIndex: Int) {
        stateController.removeCourse(at: courseIndex)
        self.tableView.deleteRows(at: [IndexPath(row: courseIndex, section: 0)], with: .left)
    }

    // MARK: - UITableViewController Overrides
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else {
            fatalError("Invalid section")
        }

        return stateController.courses.count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section == 0 else {
            fatalError("Invalid section")
        }

        let cell = UITableViewCell()
        cell.textLabel!.text = stateController.courses[indexPath.row].code
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else {
            fatalError("Invalid section")
        }

        editCourse(at: indexPath.row)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else {
            fatalError("Invalid section")
        }

        switch editingStyle {
        case .delete:
            deleteCourse(at: indexPath.row)
        default:
            fatalError("Unsupported commit operation")
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.section == 0 else {
            fatalError("Invalid section")
        }

        return true
    }
}
