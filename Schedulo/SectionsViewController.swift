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
            if let identifier = alertController.textFields?.first?.text, self.identifierIsValid(identifier) {
                self.sections.append(Section(identifier: identifier, sessions: []))
                self.tableView.insertSections([self.sections.count - 1], with: .left)
            } else {
                self.addSection()
            }
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "e.g. LEC001"
            textField.autocapitalizationType = .allCharacters
        })
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)

        self.tableView.deselectRow(at: IndexPath(row: 0, section: self.sections.count), animated: true)
    }

    private func deleteSection(at sectionIndex: Int) {
        sections.remove(at: sectionIndex)
        tableView.deleteSections([sectionIndex], with: .left)
    }

    private func addSession(to sectionIndex: Int) {
        print("Adding session")
    }

    private func editSession(_ sessionIndex: Int, of sectionIndex: Int) {
        print("Editing section")
    }

    private func identifierIsValid(_ identifier: String, for sectionIndexOrNil: Int? = nil) -> Bool {
        if identifier.isEmpty {
            return false
        }

        for (index, section) in self.sections.enumerated() {
            if let sectionIndex = sectionIndexOrNil, sectionIndex == index {
                continue
            }

            if section.identifier == identifier {
                return false
            }
        }

        return true
    }

    // MARK: - Initializers

    init(for sections: [Section], saveHandler: @escaping ([Section]) -> Void) {
        self.sections = sections
        self.saveHandler = saveHandler

        super.init(style: .grouped)

        self.navigationItem.title = "Sections"
        self.navigationItem.rightBarButtonItem = editButtonItem

        self.tableView.allowsSelectionDuringEditing = true
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

        if tableView.isEditing {
            return sections[section].sessions.count + 3
        }

        return sections[section].sessions.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()

        let effectiveRow = tableView.isEditing ? indexPath.row - 1 : indexPath.row

        switch (indexPath.section, effectiveRow) {
        case (sections.count, _):
            cell.textLabel!.text = "Add Section"
            cell.textLabel!.textColor = cell.textLabel!.tintColor
            cell.textLabel!.textAlignment = .center
        case let (section, row) where (0..<sections[section].sessions.count).contains(row):
            cell.textLabel!.text = sections[section].sessions[row].description
            cell.accessoryType = .disclosureIndicator
        case let (section, row) where row == sections[section].sessions.count:
            cell.textLabel!.text = "Add Session"
            cell.accessoryType = .disclosureIndicator
        case (let section, -1) where tableView.isEditing:
            let originalIdentifier = sections[section].identifier
            let sectionIdentifierCell = TextFieldCell {
                let sectionIndex = self.tableView.indexPath(for: cell)!.section

                if self.identifierIsValid($0, for: sectionIndex) {
                    self.sections[sectionIndex].identifier = $0
                } else {
                    self.sections[sectionIndex].identifier = originalIdentifier
                }
            }
            sectionIdentifierCell.textField.placeholder = originalIdentifier
            sectionIdentifierCell.textField.text = originalIdentifier
            cell = sectionIdentifierCell
        case let (section, row) where row == sections[section].sessions.count + 1 && tableView.isEditing:
            cell.textLabel!.text = "Delete Section"
            cell.textLabel!.textColor = .red
        default:
            break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (sections.count, _):
            addSection()
        case let (section, row) where row == sections[section].sessions.count:
            addSession(to: section)
        case let (section, row) where row == sections[section].sessions.count + 2 && tableView.isEditing:
            deleteSection(at: section)
        case let (section, row):
            editSession(row, of: section)
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section < sections.count && !tableView.isEditing ? sections[section].identifier : nil
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        tableView.reloadSections(IndexSet(0..<sections.count), with: .middle)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            deleteSection(at: indexPath.section)
        default:
            fatalError("Unsupported commit.")
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch (indexPath.section, indexPath.row) {
        case (sections.count, 0):
            return false
        case (_, 0):
            return false
        case (let section, let row) where row > sections[section].sessions.count:
            return false
        default:
            return true
        }
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch (indexPath.section, indexPath.row) {
        case (0..<sections.count, 0) where tableView.isEditing:
            return false
        default:
            return true
        }
    }
}

