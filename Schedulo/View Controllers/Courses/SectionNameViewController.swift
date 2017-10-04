//
//  SectionNameViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-10-03.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class SectionNameViewController: UITableViewController, UITextFieldDelegate {
    var stateController: StateController!
    var courseIndex: Int!
    var sectionIndex: Int!

    private var section: Section {
        get {
            return stateController.courses[courseIndex].sections[sectionIndex]
        }

        set {
            stateController.courses[courseIndex].sections[sectionIndex] = newValue
        }
    }

    override func viewDidLoad() {
        title = "Name"

        tableView.allowsSelection = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        (tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.contentView.subviews.first as? UITextField)?.becomeFirstResponder()
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

        let nameField = UITextField()

        nameField.delegate = self

        nameField.translatesAutoresizingMaskIntoConstraints = false
        nameField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        nameField.text = section.name
        nameField.returnKeyType = .done
        nameField.autocapitalizationType = .allCharacters

        cell.contentView.addSubview(nameField)

        nameField.leftAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leftAnchor).isActive = true
        nameField.rightAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.rightAnchor).isActive = true
        nameField.topAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.topAnchor).isActive = true
        nameField.bottomAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.bottomAnchor).isActive = true

        return cell
    }

    // MARK: - UITextViewDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        navigationController?.popViewController(animated: true)

        return false
    }

    @objc func editingChanged(_ textField: UITextField) {
        section.name = textField.text!.trimmingCharacters(in: .whitespaces)
    }
}
