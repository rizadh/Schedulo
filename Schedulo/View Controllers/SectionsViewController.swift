//
//  SectionsViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-26.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class SectionsViewController: UITableViewController {
    typealias CourseSectionGroups = [String: [Section]]

    // MARK: - Private Properties
    private let saveHandler: (CourseSectionGroups) -> Void
    private var sectionGroups: CourseSectionGroups {
        didSet {
            saveHandler(sectionGroups)
        }
    }

    private var expandedSection: (groupName: String, index: Int)?

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
        return sectionGroups.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < sectionGroups.count {
            let groupName = sectionGroups.keys.sorted()[section]
            return sectionGroups[groupName]!.count + 1
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        cell.textLabel?.text = "???"

        print(cellType(for: indexPath))

        return cell
    }
}

extension SectionsViewController {
    enum TableCellType {
        case section(groupName: String?, index: Int)
        case addSection(groupName: String?)
        case session(groupName: String?, sectionIndex: Int, index: Int)
        case addSession(groupName: String?, sectionIndex: Int)
        case addGroup
    }

    private func cellType(for indexPath: IndexPath) -> TableCellType {
        return tableCellTypeMatrix[indexPath.section][indexPath.row]
    }

    var tableCellTypeMatrix: [[TableCellType]] {
        var tableCells = [[TableCellType]]()

        for (groupName, sections) in sectionGroups.sorted(by: { $0.key < $1.key }) {
            tableCells.append(tableSectionCells(groupName: groupName, sections: sections))
        }

        tableCells.append([.addGroup])

        return tableCells
    }

    private func tableSectionCells(groupName: String, sections: [Section]) -> [TableCellType] {
        var cells = [TableCellType]()

        for (sectionIndex, section) in sections.enumerated() {
            cells.append(.section(groupName: groupName, index: sectionIndex))

            if let expandedSectionIndex = self.expandedSection?.index, expandedSectionIndex == sectionIndex {
                for (sessionIndex, _) in section.sessions.enumerated() {
                    cells.append(.session(groupName: groupName, sectionIndex: sectionIndex, index: sessionIndex))
                }

                cells.append(.addSession(groupName: groupName, sectionIndex: sectionIndex))
            }
        }

        cells.append(.addSection(groupName: groupName))

        return cells
    }
}
