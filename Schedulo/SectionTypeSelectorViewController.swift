//
//  SectionTypeSelectorViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-08.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class SectionTypeSelectorViewController: UITableViewController {
    // MARK: - Public Properties
    var sectionTypes = Set<SectionType>() {
        didSet {
            changeHandler(sectionTypes)
        }
    }

    var customSectionTypes: [SectionType] {
        return sectionTypes.filter { !SectionType.suggested.contains($0) }
    }

    // MARK: - Private Properties
    private let changeHandler: (Set<SectionType>) -> Void

    // MARK: - Private Constants
    private struct TableSection {
        static let suggested = 0
        static let custom = 1
    }

    // MARK: - Private Methods
    private func getSectionType(at indexPath: IndexPath) -> SectionType {
        switch (indexPath.section, indexPath.row) {
        case (TableSection.suggested, let row):
            return SectionType.suggested[row]
        case (TableSection.custom, let row):
            return customSectionTypes[row]
        default:
            fatalError("Unrecognized index path")
        }
    }

    // MARK: - Initializers
    init(changeHandler: @escaping (Set<SectionType>) -> Void) {
        self.changeHandler = changeHandler

        super.init(style: .grouped)

        self.navigationItem.title = "Select Groups"
        self.navigationItem.prompt = "Select at least one group"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UITableViewController Overrides
    override func numberOfSections(in tableView: UITableView) -> Int {
        // TODO: Re-enable custom section types
        // return 2
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case TableSection.suggested:
            return SectionType.suggested.count
        case TableSection.custom:
            return customSectionTypes.count
        default:
            fatalError("Unrecognized section")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let cellSectionType: SectionType = getSectionType(at: indexPath)

        cell.textLabel?.text = cellSectionType.description

        if sectionTypes.contains(cellSectionType) {
            cell.accessoryType = .checkmark
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case TableSection.suggested:
            // TODO: Re-enable custom section types
            // return "Suggested"
            return nil
        case TableSection.custom:
            return "Custom"
        default:
            fatalError("Unrecognized section")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellSectionType = getSectionType(at: indexPath)

        if sectionTypes.contains(cellSectionType) {
            sectionTypes.remove(cellSectionType)
        } else {
            sectionTypes.update(with: cellSectionType)
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
