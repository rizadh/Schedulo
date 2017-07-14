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

    private func updateStateBasedViews() {
        if stateController.courses.isEmpty {
            self.navigationItem.setLeftBarButton(nil, animated: true)
        } else {
            self.navigationItem.setLeftBarButton(editButtonItem, animated: true)
        }
    }

    // MARK: - Course Managing Methods
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

        let index = indexPath.row
        let course = stateController.courses[index]
        let courseDetailViewController = CourseDetailViewController(for: course) {
            self.stateController.replaceCourse(at: index, with: $0)
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }

        navigationController?.pushViewController(courseDetailViewController, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else {
            fatalError("Invalid section")
        }

        switch editingStyle {
        case .delete:
            stateController.removeCourse(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .left)
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
