//
//  SectionsViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-11.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

private extension String {
    var isValidIdentifier: Bool {
        return !self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func isValidIndentifier(forSection index: Int, in controller: SectionsViewController) -> Bool {
        if !self.isValidIdentifier {
            return false
        }

        for (sectionIndex, section) in controller.sections.enumerated() {
            if sectionIndex == index {
                continue
            }

            if self.caseInsensitiveCompare(section.identifier) == .orderedSame {
                return false
            }
        }

        return true
    }
}

class SectionsViewController: UITableViewController {
    // MARK: - Public Properties
    var sectionType: String?

    // MARK: - Private Properties

    // MARK: Alert Handling
    private var textFieldChangeHandler: TextFieldChangeHandler!

    // MARK: Sections Management
    fileprivate var sections: [Section] {
        didSet {
            updateEditButtonVisibility()
            saveHandler(sections)
        }
    }
    private let saveHandler: ([Section]) -> Void

    // MARK: - Private Methods

    private func updateEditButtonVisibility() {
        if sections.isEmpty {
            super.setEditing(false, animated: true)
            navigationItem.setRightBarButton(nil, animated: true)
        } else {
            navigationItem.setRightBarButton(editButtonItem, animated: true)
        }
    }

    private func addSection() {
        func addSection(with identifier: String) {
            self.sections.append(Section(identifier: identifier, sessions: []))
            self.tableView.insertSections([self.sections.count - 1], with: .fade)
        }

        let alertController = UIAlertController(title: "New Section", message: "Enter a unique identifier for the section.", preferredStyle: .alert)

        let doneAction = UIAlertAction(title: "Done", style: .default, handler: { _ in
            let identifier = alertController.textFields!.first!.text!

            addSection(with: identifier)
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        self.textFieldChangeHandler = TextFieldChangeHandler { textField in
            if textField.text!.isValidIdentifier {
                doneAction.isEnabled = true
            } else {
                doneAction.isEnabled = false
            }
        }

        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "e.g. LEC001"
            textField.autocapitalizationType = .allCharacters
            textField.addTarget(self.textFieldChangeHandler, action: #selector(self.textFieldChangeHandler.textFieldDidChange(_:)), for: .allEditingEvents)

            let validIdentifiers = self.generateIdentifierSuggestions().filter {
                $0.isValidIdentifier
            }

            if !validIdentifiers.isEmpty {
                textField.inputAccessoryView = InputSuggestionView(with: validIdentifiers) { selectedOption in
                    addSection(with: selectedOption)
                    alertController.dismiss(animated: true, completion: nil)
                }
            }
        })
        alertController.addAction(doneAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)

        self.tableView.deselectRow(at: IndexPath(row: 0, section: self.sections.count), animated: true)
    }

    private func deleteSection(at sectionIndex: Int) {
        sections.remove(at: sectionIndex)
        tableView.deleteSections([sectionIndex], with: .left)
    }

    private func addSession(to sectionIndex: Int) {
        let newSessionIndex = sections[sectionIndex].sessions.count

        let controller = SessionDetailViewController(for: nil) {
            if let indexPath = self.indexPath(for: .section(index: sectionIndex), .session(index: newSessionIndex)) {
                self.sections[sectionIndex].sessions[newSessionIndex] = $0
                self.tableView.reloadRows(at: [indexPath], with: .none)
            } else {
                self.sections[sectionIndex].sessions.append($0)
                let indexPath = self.indexPath(for: .section(index: sectionIndex), .session(index: newSessionIndex))!
                self.tableView.insertRows(at: [indexPath], with: .none)
            }
        }

        navigationController?.pushViewController(controller, animated: true)
    }

    private func editSession(_ sessionIndex: Int, of sectionIndex: Int) {
        let session = self.sections[sectionIndex].sessions[sessionIndex]
        let indexPath = self.indexPath(for: .section(index: sectionIndex), .session(index: sessionIndex))!
        let controller = SessionDetailViewController(for: session) {
            self.sections[sectionIndex].sessions[sessionIndex] = $0
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }

        navigationController?.pushViewController(controller, animated: true)
    }

    private func deleteSession(_ sessionIndex: Int, of sectionIndex: Int) {
        let indexPath = self.indexPath(for: .section(index: sectionIndex), .session(index: sessionIndex))!

        self.sections[sectionIndex].sessions.remove(at: sessionIndex)
        self.tableView.deleteRows(at: [indexPath], with: .left)
    }

    private func generateIdentifierSuggestions() -> [String] {
        let parsedIdentifiers = sections.flatMap {
            return parseIdentifier($0.identifier)
        }

        let prefixes = Set(parsedIdentifiers.map({ $0.prefix }))

        let suggestionsBasedOnExistingSections: [String] = prefixes.map { prefix in
            let maxValue = parsedIdentifiers.filter { $0.prefix == prefix }.map { $0.value }.reduce(0, max)
            let maxDigits = parsedIdentifiers.filter { $0.prefix == prefix }.map { $0.digits }.reduce(0, max)

            let suffix = String(format: "%0\(maxDigits)d", maxValue + 1)

            return prefix + suffix
        }

        if suggestionsBasedOnExistingSections.isEmpty {
            return [String((sectionType ?? "Section").prefix(3)).uppercased() + "01"]
        } else {
            return suggestionsBasedOnExistingSections
        }
    }

    private func parseIdentifier(_ identifier: String) -> (prefix: String, digits: Int, value: Int)? {
        let pattern = "^(.*?)(\\d+)$"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])

        guard let match = regex.firstMatch(in: identifier, options: [], range: NSRange(location: 0, length: identifier.count)) else {
            return nil
        }

        let prefixRange = match.range(at: 1)
        let valueRange = match.range(at: 2)

        let prefix = String((identifier as NSString).substring(with: prefixRange))
        let valueAsString = String((identifier as NSString).substring(with: valueRange))

        let digits = valueAsString.count
        let value = Int(valueAsString)!

        return (prefix, digits, value)
    }

    // MARK: - Initializers

    init(for sections: [Section], saveHandler: @escaping ([Section]) -> Void) {
        self.sections = sections
        self.saveHandler = saveHandler

        super.init(style: .grouped)

        self.navigationItem.title = "Sections"
        updateEditButtonVisibility()

        self.tableView.allowsSelectionDuringEditing = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewController Overrides
extension SectionsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count + 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableSection(at: section) {
        case .section(let sectionIndex):
            let numberOfSessions = sections[sectionIndex].sessions.count

            if tableView.isEditing {
                return numberOfSessions + 3
            } else {
                return numberOfSessions + 1
            }
        case .addSection:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()

        guard let (section, row) = tableSectionAndRow(for: indexPath) else {
            return cell
        }

        switch section {
        case .section(let sectionIndex):
            switch row {
            case .identifier:
                let originalIdentifier = sections[indexPath.section].identifier
                let sectionIdentifierCell = TextFieldCell {
                    if $0.isValidIndentifier(forSection: sectionIndex, in: self) {
                        self.sections[sectionIndex].identifier = $0.uppercased()
                    } else {
                        self.sections[sectionIndex].identifier = originalIdentifier
                    }

                    tableView.reloadSections([sectionIndex], with: .none)
                }
                sectionIdentifierCell.textField.placeholder = originalIdentifier
                sectionIdentifierCell.textField.text = originalIdentifier
                cell = sectionIdentifierCell
            case .session(let sessionIndex):
                cell.textLabel!.text = sections[sectionIndex].sessions[sessionIndex].description
                cell.accessoryType = .disclosureIndicator
            case .addSession:
                cell.textLabel!.text = "Add Session"
                cell.accessoryType = .disclosureIndicator
            case .deleteSection:
                cell.textLabel!.text = "Delete Section"
                cell.textLabel!.textColor = .red
            default:
                break
            }
        case .addSection:
            cell.textLabel!.text = "Add Section"
            cell.textLabel!.textColor = cell.textLabel!.tintColor
            cell.textLabel!.textAlignment = .center
        }

        cell.clipsToBounds = true

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let (section, row) = tableSectionAndRow(for: indexPath) else {
            return
        }

        switch section {
        case .section(let sectionIndex):
            switch row {
            case .session(let sessionIndex):
                editSession(sessionIndex, of: sectionIndex)
            case .addSession:
                addSession(to: sectionIndex)
            case .deleteSection:
                deleteSection(at: sectionIndex)
            default:
                break
            }
        case .addSection:
            addSection()
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch tableSection(at: section) {
        case .section(let sectionIndex):
            return sections[sectionIndex].identifier
        default:
            return nil
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        func showEditingRows() {
            for sectionIndex in 0..<sections.count {
                let identifierIndexPath = indexPath(for: .section(index: sectionIndex), .identifier)!
                let deleteSectionIndexPath = indexPath(for: .section(index: sectionIndex), .deleteSection)!

                tableView.insertRows(at: [identifierIndexPath], with: .bottom)
                tableView.insertRows(at: [deleteSectionIndexPath], with: .top)
            }
        }

        func hideEditingRows() {
            for sectionIndex in 0..<sections.count {
                let identifierIndexPath = indexPath(for: .section(index: sectionIndex), .identifier)!
                let deleteSectionIndexPath = indexPath(for: .section(index: sectionIndex), .deleteSection)!

                tableView.deleteRows(at: [identifierIndexPath], with: .bottom)
                tableView.deleteRows(at: [deleteSectionIndexPath], with: .top)
            }
        }

        let updateFunction: () -> Void

        switch (tableView.isEditing, editing) {
        case (false, true):
            updateFunction = {
                super.setEditing(editing, animated: animated)
                showEditingRows()
            }
        case (true, false):
            updateFunction = {
                hideEditingRows()
                super.setEditing(editing, animated: animated)
            }
        default:
            updateFunction = {
                super.setEditing(editing, animated: animated)
            }
        }

        if #available(iOS 11, *) {
            tableView.performBatchUpdates({
                updateFunction()
            }, completion: nil)
        } else {
            tableView.beginUpdates()
            updateFunction()
            tableView.endUpdates()
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if case .delete = editingStyle {
            guard let (section, row) = tableSectionAndRow(for: indexPath) else {
                return
            }

            if case .section(let sectionIndex) = section {
                if case .session(let sessionIndex) = row {
                    deleteSession(sessionIndex, of: sectionIndex)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let (section, row) = tableSectionAndRow(for: indexPath), case .section = section, case .session = row else {
            return false
        }

        return true
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let (_, row) = tableSectionAndRow(for: indexPath), case .identifier = row else {
            return true
        }

        return false
    }
}

// MARK: - Cell Identification
extension SectionsViewController {
    private enum TableSection {
        case section(index: Int)
        case addSection
    }

    private enum TableRow {
        case identifier
        case session(index: Int)
        case addSession
        case deleteSection

        case addSection
    }

    private func tableSection(at index: Int) -> TableSection {
        if index < sections.count {
            return .section(index: index)
        } else {
            return .addSection
        }
    }

    private func tableSectionAndRow(for indexPath: IndexPath) -> (section: TableSection, row: TableRow)? {
        if indexPath.section == sections.count {
            return (.addSection, .addSection)
        }

        guard indexPath.section < sections.count else {
            return nil
        }

        let tableSection = TableSection.section(index: indexPath.section)
        let tableRow: TableRow

        let numberOfSessions = sections[indexPath.section].sessions.count

        if tableView.isEditing {
            switch indexPath.row {
            case 0:
                tableRow = .identifier
            case 1..<numberOfSessions + 1:
                tableRow = .session(index: indexPath.row - 1)
            case numberOfSessions + 1:
                tableRow = .addSession
            case numberOfSessions + 2:
                tableRow = .deleteSection
            default:
                return nil
            }
        } else {
            switch indexPath.row {
            case 0..<numberOfSessions:
                tableRow = .session(index: indexPath.row)
            case numberOfSessions:
                tableRow = .addSession
            default:
                return nil
            }
        }

        return (tableSection, tableRow)
    }

    private func indexPath(for section: TableSection, _ row: TableRow) -> IndexPath? {
        if tableView.isEditing {
            switch section {
            case .section(let sectionIndex):
                let numberOfSessions = sections[sectionIndex].sessions.count
                let rowIndexOrNil: Int?

                switch row {
                case .identifier:
                    rowIndexOrNil = 0
                case .session(index: let sessionIndex):
                    if sessionIndex < numberOfSessions {
                        rowIndexOrNil = sessionIndex + 1
                    } else {
                        rowIndexOrNil = nil
                    }
                case .addSession:
                    rowIndexOrNil = numberOfSessions + 1
                case .deleteSection:
                    rowIndexOrNil = numberOfSessions + 2
                default:
                    rowIndexOrNil = nil
                }

                guard let tableRow = rowIndexOrNil else {
                    return nil
                }

                return IndexPath(row: tableRow, section: sectionIndex)
            case .addSection:
                return IndexPath(row: 0, section: sections.count)
            }
        } else {
            switch section {
            case .section(let sectionIndex):
                let numberOfSessions = sections[sectionIndex].sessions.count
                let rowIndexOrNil: Int?

                switch row {
                case .session(index: let sessionIndex):
                    if sessionIndex < numberOfSessions {
                        rowIndexOrNil = sessionIndex
                    } else {
                        rowIndexOrNil = nil
                    }
                case .addSession:
                    rowIndexOrNil = numberOfSessions
                default:
                    rowIndexOrNil = nil
                }

                guard let tableRow = rowIndexOrNil else {
                    return nil
                }

                return IndexPath(row: tableRow, section: sectionIndex)
            case .addSection:
                return IndexPath(row: 0, section: sections.count)
            }
        }
    }
}
