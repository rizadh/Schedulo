//
//  SectionsViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-11.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class SectionsViewController: UITableViewController {
    // MARK: - Private Properties

    private var sections: [Section] {
        didSet {
            saveHandler(sections)
        }
    }
    private let saveHandler: ([Section]) -> Void

    // MARK: - Private Methods
    private func addSection() {
        let alertController = UIAlertController(title: "Add Section", message: "Enter a uniquely identifying name for the section. It cannot be blank.", preferredStyle: .alert)

        let addAction = UIAlertAction(title: "Add", style: .default, handler: { _ in
            if let identifier = alertController.textFields?.first?.text, !identifier.isEmpty {
                self.sections.append(Section(identifier: identifier, sessions: []))
                self.tableView.insertSections([self.sections.count - 1], with: .automatic)
                self.tableView.deselectRow(at: IndexPath(row: 0, section: self.sections.count), animated: true)
            } else {
                self.addSection()
            }
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.tableView.deselectRow(at: IndexPath(row: 0, section: self.sections.count), animated: true)
        })

        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "e.g. LEC001"
            textField.autocapitalizationType = .allCharacters
        })
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    private func editSession(_ sessionIndex: Int, ofSection sectionIndex: Int) {
        print("Adding session")
    }

    // MARK: - Initializers

    init(for sections: [Section], saveHandler: @escaping ([Section]) -> Void) {
        self.sections = sections
        self.saveHandler = saveHandler

        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UITableViewController Overrides

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count + 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == sections.count {
            return 1
        }

        return sections[section].sessions.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        switch (indexPath.section, indexPath.row) {
        case (sections.count, _):
            cell.textLabel!.text = "Add Section"
            cell.textLabel!.textColor = cell.textLabel!.tintColor
            cell.textLabel!.textAlignment = .center
        case (let section, let row):
            if (row == sections[section].sessions.count) {
                cell.textLabel!.text = "Add Session"
            } else {
                cell.textLabel!.text = sections[section].sessions[row].description
            }

            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (sections.count, _):
            addSection()
        case (let section, let row):
            editSession(row, ofSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section < sections.count ? sections[section].identifier : nil
    }
}

