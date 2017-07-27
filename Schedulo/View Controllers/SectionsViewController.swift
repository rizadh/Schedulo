//
//  SectionsViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-26.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class SectionsViewController: UITableViewController {
    typealias CourseSectionGroups = [SectionGroup]

    // MARK: - Private Properties
    private let saveHandler: (CourseSectionGroups) -> Void
    private var sectionGroups: CourseSectionGroups {
        didSet {
            saveHandler(sectionGroups)
        }
    }

    private var expandedSection: (groupIndex: Int, sectionIndex: Int)?

    private var textFieldChangeHandler: TextFieldChangeHandler?

    // MARK: - Private Methods

    // MARK: Section Group Name Validation
    private func sectionGroupCanBeNamed(_ groupName: String) -> Bool {
        return !groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func sectionGroupExists(named groupName: String) -> Bool {
        return sectionGroups.map { $0.name }.contains(groupName)
    }

    private func newSectionGroupCanBeCreated(named groupName: String) -> Bool {
        return sectionGroupCanBeNamed(groupName) && !sectionGroupExists(named: groupName)
    }

    // MARK: Section Group Management
    private func addSectionGroup() {
        let alertTitle = "New Group"
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default, handler: { _ in
            guard let groupName = alertController.textFields?.first?.text else {
                return
            }

            let newGroup = SectionGroup(name: groupName, sections: [])

            self.sectionGroups.append(newGroup)

            self.tableView.insertSections([self.sectionGroups.count - 1], with: .automatic)
        })

        addAction.isEnabled = false

        self.textFieldChangeHandler = TextFieldChangeHandler { textField in
            guard let groupName = textField.text else {
                addAction.isEnabled = false
                return
            }

            addAction.isEnabled = self.newSectionGroupCanBeCreated(named: groupName)
        }

        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        alertController.addTextField { textField in
            textField.autocapitalizationType = .words
            textField.clearButtonMode = .always
            textField.placeholder = "Choose a name"

            let groupNameSuggestions = ["Lecture", "Tutorial", "Practical", "Lab"].filter(self.newSectionGroupCanBeCreated)

            if !groupNameSuggestions.isEmpty {
                textField.inputAccessoryView = InputSuggestionView(with: groupNameSuggestions) { selectedSuggestion in
                    textField.text = selectedSuggestion
                    self.textFieldChangeHandler?.textFieldDidChange(textField)
                }
            }

            textField.addTarget(self.textFieldChangeHandler, action: #selector(self.textFieldChangeHandler?.textFieldDidChange(_:)), for: .editingChanged)
        }

        present(alertController, animated: true, completion: nil)
    }

    private func deleteSectionGroup(at groupIndex: Int) {
        sectionGroups.remove(at: groupIndex)
        tableView.deleteSections([groupIndex], with: .automatic)
    }

    // MARK: Section Name Validation
    private func sectionCanBeNamed(_ sectionName: String) -> Bool {
        return !sectionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func sectionExists(in groupIndex: Int, named sectionName: String) -> Bool {
        return sectionGroups[groupIndex].sections.map { $0.name }.contains(sectionName)
    }

    private func newSectionCanBeCreated(in groupIndex: Int, named sectionName: String) -> Bool {
        return sectionCanBeNamed(sectionName) && !sectionExists(in: groupIndex, named: sectionName)
    }

    // MARK: Section Name Suggestions
    private func generateSectionNameSuggestions(for groupIndex: Int) -> [String] {
        let group = sectionGroups[groupIndex]

        let parsedSectionNames = group.sections.flatMap {
            return parseSectionName($0.name)
        }

        let prefixes = Set(parsedSectionNames.map({ $0.prefix }))

        let suggestionsBasedOnExistingSections: [String] = prefixes.map { prefix in
            let maxValue = parsedSectionNames.filter { $0.prefix == prefix }.map { $0.value }.reduce(0, max)
            let maxDigits = parsedSectionNames.filter { $0.prefix == prefix }.map { $0.digits }.reduce(0, max)

            let suffix = String(format: "%0\(maxDigits)d", maxValue + 1)

            return prefix + suffix
        }

        if suggestionsBasedOnExistingSections.isEmpty {
            return [
                String(group.name.prefix(3)).uppercased() + "0001",
                String(group.name.prefix(4)).uppercased() + "001",
                "1"
            ]
        } else {
            return suggestionsBasedOnExistingSections
        }
    }

    private func parseSectionName(_ sectionName: String) -> (prefix: String, digits: Int, value: Int)? {
        let pattern = "^(.*?)(\\d+)$"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])

        guard let match = regex.firstMatch(in: sectionName, options: [], range: NSRange(location: 0, length: sectionName.count)) else {
            return nil
        }

        let prefixRange = match.range(at: 1)
        let valueRange = match.range(at: 2)

        let prefix = String((sectionName as NSString).substring(with: prefixRange))
        let valueAsString = String((sectionName as NSString).substring(with: valueRange))

        let digits = valueAsString.count
        let value = Int(valueAsString)!

        return (prefix, digits, value)
    }


    // MARK: Section Management
    private func addSection(to groupIndex: Int) {
        let alertTitle = "New Section"
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default, handler: { _ in
            guard let sectionName = alertController.textFields?.first?.text else {
                return
            }

            let newSection = Section(name: sectionName, sessions: [])

            self.sectionGroups[groupIndex].sections.append(newSection)

            let indexPath = self.indexPath(for: .section(groupIndex: groupIndex, sectionIndex: self.sectionGroups[groupIndex].sections.count - 1))!

            self.tableView.insertRows(at: [indexPath], with: .automatic)
        })

        addAction.isEnabled = false

        self.textFieldChangeHandler = TextFieldChangeHandler { textField in
            guard let sectionName = textField.text else {
                addAction.isEnabled = false
                return
            }

            addAction.isEnabled = self.newSectionCanBeCreated(in: groupIndex, named: sectionName)
        }

        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        alertController.addTextField { textField in
            textField.autocapitalizationType = .words
            textField.clearButtonMode = .always
            textField.placeholder = "Choose a name"

            let suggestedSectionNames = self.generateSectionNameSuggestions(for: groupIndex)

            if !suggestedSectionNames.isEmpty {
                textField.inputAccessoryView = InputSuggestionView(with: suggestedSectionNames) { selectedSuggestion in
                    textField.text = selectedSuggestion
                    self.textFieldChangeHandler?.textFieldDidChange(textField)
                }
            }

            textField.addTarget(self.textFieldChangeHandler, action: #selector(self.textFieldChangeHandler?.textFieldDidChange(_:)), for: .editingChanged)
        }

        present(alertController, animated: true, completion: nil)
    }

    private func renameSection(in groupIndex: Int, at sectionIndex: Int) {
        let alertTitle = "Rename Section"
        let alertController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Done", style: .default, handler: { _ in
            guard let sectionName = alertController.textFields?.first?.text else {
                return
            }

            self.sectionGroups[groupIndex].sections[sectionIndex].name = sectionName

            let indexPath = self.indexPath(for: .section(groupIndex: groupIndex, sectionIndex: sectionIndex))!

            self.tableView.reloadRows(at: [indexPath], with: .fade)
        })

        addAction.isEnabled = false

        self.textFieldChangeHandler = TextFieldChangeHandler { textField in
            guard let sectionName = textField.text else {
                addAction.isEnabled = false
                return
            }

            addAction.isEnabled = self.newSectionCanBeCreated(in: groupIndex, named: sectionName)
        }

        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        alertController.addTextField { textField in
            textField.autocapitalizationType = .words
            textField.clearButtonMode = .always
            textField.placeholder = self.sectionGroups[groupIndex].sections[sectionIndex].name

            textField.addTarget(self.textFieldChangeHandler, action: #selector(self.textFieldChangeHandler?.textFieldDidChange(_:)), for: .editingChanged)
        }

        present(alertController, animated: true, completion: nil)
    }

    private func toggleSectionExpansion(at indexPath: IndexPath) {
        guard case let .section(groupIndex, sectionIndex) = cellType(for: indexPath) else {
            fatalError("Can only expand a section cell")
        }

        if let (expandedGroupIndex, expandedSectionIndex) = expandedSection {
            if expandedGroupIndex == groupIndex && expandedSectionIndex == sectionIndex {
                expandedSection = nil

                let sessionsToCollapse = sectionGroups[groupIndex].sections[sectionIndex].sessions.count
                let indexPathsToCollapse = (1...sessionsToCollapse + 1).map { IndexPath(row: sectionIndex + $0, section: groupIndex) }

                tableView.deleteRows(at: indexPathsToCollapse, with: .top)
            } else {
                expandedSection = (groupIndex, sectionIndex)

                let sessionsToExpand = sectionGroups[groupIndex].sections[sectionIndex].sessions.count
                let indexPathsToExpand = (1...sessionsToExpand + 1).map { IndexPath(row: sectionIndex + $0, section: groupIndex) }

                let sessionsToCollapse = sectionGroups[expandedGroupIndex].sections[expandedSectionIndex].sessions.count
                let indexPathsToCollapse = (1...sessionsToCollapse + 1).map { IndexPath(row: expandedSectionIndex + $0, section: expandedGroupIndex) }

                tableView.beginUpdates()
                tableView.insertRows(at: indexPathsToExpand, with: .top)
                tableView.deleteRows(at: indexPathsToCollapse, with: .top)
                tableView.endUpdates()
            }
        } else {
            expandedSection = (groupIndex, sectionIndex)

            let sessionsToExpand = sectionGroups[groupIndex].sections[sectionIndex].sessions.count
            let indexPathsToExpand = (1...sessionsToExpand + 1).map { IndexPath(row: sectionIndex + $0, section: groupIndex) }

            tableView.insertRows(at: indexPathsToExpand, with: .top)
        }
    }

    // MARK: Session Management

    private func addSession(inSection sectionIndex: Int, inGroup groupIndex: Int) {
        let sessionDetailViewController = SessionDetailViewController(for: nil) { newSession in
            self.sectionGroups[groupIndex].sections[sectionIndex].sessions.append(newSession)

            let newSessionIndex = self.sectionGroups[groupIndex].sections[sectionIndex].sessions.count - 1

            let indexPath = self.indexPath(for: .session(groupIndex: groupIndex, sectionIndex: sectionIndex, sessionIndex: newSessionIndex))!

            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            self.tableView.reloadRows(at: [self.indexPath(for: .section(groupIndex: groupIndex, sectionIndex: sectionIndex))!], with: .automatic)
            self.tableView.endUpdates()
        }

        navigationController?.pushViewController(sessionDetailViewController, animated: true)
    }

    private func editSession(at sessionIndex: Int, inSection sectionIndex: Int, inGroup groupIndex: Int) {
        let session = self.sectionGroups[groupIndex].sections[sectionIndex].sessions[sessionIndex]

        let sessionDetailViewController = SessionDetailViewController(for: session) { newSession in
            self.sectionGroups[groupIndex].sections[sectionIndex].sessions[sessionIndex] = newSession

            let indexPath = self.indexPath(for: .session(groupIndex: groupIndex, sectionIndex: sectionIndex, sessionIndex: sessionIndex))!

            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }

        navigationController?.pushViewController(sessionDetailViewController, animated: true)
    }

    private func deleteSession(at sessionIndex: Int, inSection sectionIndex: Int, inGroup groupIndex: Int) {
        let indexPath = self.indexPath(for: .session(groupIndex: groupIndex, sectionIndex: sectionIndex, sessionIndex: sessionIndex))!

        sectionGroups[groupIndex].sections[sectionIndex].sessions.remove(at: sessionIndex)

        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadRows(at: [self.indexPath(for: .section(groupIndex: groupIndex, sectionIndex: sectionIndex))!], with: .fade)
        tableView.endUpdates()
    }

    // MARK: - Initializers
    init(for sections: CourseSectionGroups, saveHandler: @escaping (CourseSectionGroups) -> Void) {
        self.saveHandler = saveHandler
        self.sectionGroups = sections

        super.init(style: .grouped)

        self.navigationItem.title = "Sections"
        if #available(iOS 11, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewController Method Overrides
extension SectionsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionGroups.count + 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < sectionGroups.count {
            if let (groupIndex, sectionIndex) = expandedSection, groupIndex == section {
                let sessionCount = sectionGroups[groupIndex].sections[sectionIndex].sessions.count

                return sectionGroups[section].sections.count + sessionCount + 2
            } else {
                return sectionGroups[section].sections.count + 1
            }
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < sectionGroups.count {
            return sectionGroups[section].name
        } else {
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        switch cellType(for: indexPath) {
        case .session, .addSession:
            return 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let cellType = self.cellType(for: indexPath)

        switch cellType {
        case .addGroup:
            cell.textLabel?.text = "Add Group"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = cell.textLabel?.tintColor
        case .addSection:
            cell.textLabel?.text = "Add Section"
            cell.textLabel?.textColor = cell.textLabel?.tintColor
        case let .section(groupIndex, sectionIndex):
            let sectionCell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            let section = sectionGroups[groupIndex].sections[sectionIndex]

            sectionCell.textLabel?.text = section.name
            sectionCell.accessoryType = .detailButton

            let sessionCount = section.sessions.count

            switch sessionCount {
            case 0:
                sectionCell.detailTextLabel?.text = "No sessions"
            case 1:
                sectionCell.detailTextLabel?.text = "1 session"
            default:
                sectionCell.detailTextLabel?.text = "\(sessionCount) session"
            }

            return sectionCell
        case let .session(groupIndex, sectionIndex, sessionIndex):
            let session = sectionGroups[groupIndex].sections[sectionIndex].sessions[sessionIndex]

            cell.textLabel?.text = "\(session)"
            cell.accessoryType = .disclosureIndicator
        case .addSession:
            cell.textLabel?.text = "New Time"
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch cellType(for: indexPath) {
        case .addGroup:
            tableView.deselectRow(at: indexPath, animated: true)
            addSectionGroup()
        case let .addSection(groupIndex):
            tableView.deselectRow(at: indexPath, animated: true)
            addSection(to: groupIndex)
        case .section:
            tableView.deselectRow(at: indexPath, animated: true)
            toggleSectionExpansion(at: indexPath)
        case let .addSession(groupIndex, sectionIndex):
            addSession(inSection: sectionIndex, inGroup: groupIndex)
        case let .session(groupIndex, sectionIndex, sessionIndex):
            editSession(at: sessionIndex, inSection: sectionIndex, inGroup: groupIndex)
        }
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        switch cellType(for: indexPath) {
        case let .section(groupIndex, sectionIndex):
            renameSection(in: groupIndex, at: sectionIndex)
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if case .delete = editingStyle {
            switch cellType(for: indexPath) {
            case let .addSection(groupIndex):
                deleteSectionGroup(at: groupIndex)
            case let .session(groupIndex, sectionIndex, sessionIndex):
                deleteSession(at: sessionIndex, inSection: sectionIndex, inGroup: groupIndex)
            default:
                break
            }
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch cellType(for: indexPath) {
        case .addSection, .section, .session:
            return true
        case .addGroup, .addSession:
            return false
        }
    }

    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        switch cellType(for: indexPath) {
        case .addSection:
            return "Delete Group"
        default:
            return "Delete"
        }
    }
}


// MARK: - Cell Type Identification
extension SectionsViewController {
    enum TableCellType: Equatable {
        case addGroup
        case addSection(groupIndex: Int)
        case section(groupIndex: Int, sectionIndex: Int)
        case addSession(groupIndex: Int, sectionIndex: Int)
        case session(groupIndex: Int, sectionIndex: Int, sessionIndex: Int)

        static func == (lhs: TableCellType, rhs: TableCellType) -> Bool {
            switch (lhs, rhs) {
            case (.addGroup, .addGroup):
                return true
            case let (.addSection(lhsGroupIndex), .addSection(rhsGroupIndex)):
                return lhsGroupIndex == rhsGroupIndex
            case let (.section(lhsGroupIndex, lhsSectionIndex), .section(rhsGroupIndex, rhsSectionIndex)):
                return lhsGroupIndex == rhsGroupIndex && lhsSectionIndex == rhsSectionIndex
            case let (.addSession(lhsGroupIndex, lhsSectionIndex), .addSession(rhsGroupIndex, rhsSectionIndex)):
                return lhsGroupIndex == rhsGroupIndex && lhsSectionIndex == rhsSectionIndex
            case let (.session(lhsGroupIndex, lhsSectionIndex, lhsSessionIndex), .session(rhsGroupIndex, rhsSectionIndex, rhsSessionIndex)):
                return lhsGroupIndex == rhsGroupIndex && lhsSectionIndex == rhsSectionIndex && lhsSessionIndex == rhsSessionIndex
            default:
                return false
            }
        }
    }

    private func cellType(for indexPath: IndexPath) -> TableCellType {
        return tableCellTypeMatrix[indexPath.section][indexPath.row]
    }

    private func indexPath(for cellType: TableCellType) -> IndexPath? {
        let matrix = tableCellTypeMatrix

        for (sectionIndex, section) in matrix.enumerated() {
            for (rowIndex, row) in section.enumerated() {
                if row == cellType {
                    return IndexPath(row: rowIndex, section: sectionIndex)
                }
            }
        }

        return nil
    }

    var tableCellTypeMatrix: [[TableCellType]] {
        var tableCells = [[TableCellType]]()

        for (groupIndex, group) in sectionGroups.enumerated() {
            var sectionCells = [TableCellType]()

            for (sectionIndex, section) in group.sections.enumerated() {
                sectionCells.append(.section(groupIndex: groupIndex, sectionIndex: sectionIndex))

                if let expandedSection = self.expandedSection, expandedSection.groupIndex == groupIndex, expandedSection.sectionIndex == sectionIndex {
                    for (sessionIndex, _) in section.sessions.enumerated() {
                        sectionCells.append(.session(groupIndex: groupIndex, sectionIndex: sectionIndex, sessionIndex: sessionIndex))
                    }

                    sectionCells.append(.addSession(groupIndex: groupIndex, sectionIndex: sectionIndex))
                }
            }

            sectionCells.append(.addSection(groupIndex: groupIndex))

            tableCells.append(sectionCells)
        }

        tableCells.append([.addGroup])

        return tableCells
    }
}

