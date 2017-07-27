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
            // TODO: Handle expanded section case
            return sectionGroups[section].sections.count + 1
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        let currentCellType = cellType(for: indexPath)

        switch currentCellType {
        case .addGroup:
            cell.textLabel?.text = "Add Group"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = cell.textLabel?.tintColor
        default:
            cell.textLabel?.text = "???"
        }

        print(cellType(for: indexPath))

        return cell
    }
}

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
