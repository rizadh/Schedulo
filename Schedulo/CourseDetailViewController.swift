//
//  CourseDetailViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-01.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class CourseDetailViewController: UITableViewController {

    // MARK: - Private Properties
    private let saveHandler: (Course) -> Void
    private var course: Course {
        didSet {
            self.saveButton.isEnabled = !course.code.isEmpty
        }
    }
    private let isNewCourse: Bool
    private var saveButton: UIBarButtonItem!
    private var cancelButton: UIBarButtonItem!

    // MARK: - Initializers
    init(for courseOrNil: Course? = nil, saveHandler: @escaping (Course) -> Void) {
        self.saveHandler = saveHandler
        if let course = courseOrNil {
            isNewCourse = false
            self.course = course
        } else {
            isNewCourse = true
            self.course = Course(code: "", sections: [:])
        }

        super.init(style: .grouped)

        saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveCourse))
        cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))

        self.navigationItem.title = isNewCourse ? "New Course" : "Edit Course"
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.leftBarButtonItem = cancelButton

        saveButton.isEnabled = !isNewCourse
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Button Handlers
    @objc
    private func saveCourse() {
        saveHandler(course)
        hideKeyboardAndDismiss()
    }

    @objc
    private func cancel() {
        hideKeyboardAndDismiss()
    }

    private func hideKeyboardAndDismiss() {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UITableViewController Overrides
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TextFieldCell { newCourseCode in
            self.course.code = newCourseCode
        }
        cell.textField.text = course.code
        cell.textField.placeholder = "Course Code (Required)"
        return cell
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
