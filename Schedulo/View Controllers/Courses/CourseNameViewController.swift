//
//  CourseNameViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-10-03.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class CourseNameViewController: UITableViewController, UITextFieldDelegate {
    var stateController: StateController!
    var courseIndex: Int!

    lazy var courseNameField: UITextField = {
        let textField = UITextField()

        textField.delegate = self

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = course.name
        textField.returnKeyType = .done
        textField.autocapitalizationType = .allCharacters

        return textField
    }()

    private var course: Course {
        get {
            return stateController.courses[courseIndex]
        }

        set {
            stateController.courses[courseIndex] = newValue
        }
    }

    override func viewDidLoad() {
        title = "Course Name"

        tableView.allowsSelection = false

        courseNameField.becomeFirstResponder()
    }

    // MARK: - UITableViewController Overrides
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        cell.contentView.addSubview(courseNameField)

        courseNameField.leftAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leftAnchor).isActive = true
        courseNameField.rightAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.rightAnchor).isActive = true
        courseNameField.topAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.topAnchor).isActive = true
        courseNameField.bottomAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.bottomAnchor).isActive = true

        return cell
    }

    // MARK: - UITextViewDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        navigationController?.popViewController(animated: true)

        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        course.name = textField.text!

        return true
    }
}
