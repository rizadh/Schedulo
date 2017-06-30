//
//  SectionTableViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-29.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class SectionViewController: UITableViewController, TextFieldCellDelegate {
    let SECTION_INFORMATION_SECTION = 0
    let SESSIONS_SECTION = 1

    var section: Section {
        didSet {
            updateSubviews()
            changeHandler(section)
        }
    }
    var sessions: [Session] {
        get {
            return section.sessions
        }

        set {
            section.sessions = newValue
        }
    }

    lazy var sectionIdentifierField: TextFieldCell = {
        let cell = TextFieldCell()

        cell.textLabel?.text = "Identifier"
        cell.textField.placeholder = "001"
        cell.selectionStyle = .none

        cell.delegate = self

        return cell
    }()

    @nonobjc
    func valueDidChange(in textFieldCell: TextFieldCell, to newValue: String?) {
        section.identifier = newValue ?? ""
    }

    let changeHandler: (Section) -> Void

    private func updateSubviews() {
        navigationItem.title = section.identifier
    }

    init(for section: Section, changeHandler: @escaping (Section) -> Void) {
        self.section = section
        self.changeHandler = changeHandler

        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SECTION_INFORMATION_SECTION:
            return "Section Information"
        case SESSIONS_SECTION:
            return "Sessions"
        default:
            fatalError("Unrecognized section")
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_INFORMATION_SECTION:
            return 1
        case SESSIONS_SECTION:
            return self.section.sessions.count + 1
        default:
            fatalError("Unrecognized section")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case SECTION_INFORMATION_SECTION:
            return sectionIdentifierField
        case SESSIONS_SECTION:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.accessoryType = .disclosureIndicator

            if indexPath.row < section.sessions.count {
                let session = sessions[indexPath.row]

                if section.identifier.isEmpty {
                    cell.textLabel?.text = "New Session"
                    cell.textLabel?.textColor = .lightGray
                } else {
                    cell.textLabel?.text = "\(session.time)"
                    cell.detailTextLabel?.text = "\(session.day)"
                }
            } else {
                cell.textLabel?.text = "Add New Session"
            }
            return cell
        default:
            fatalError("Unrecognized section")
        }
    }
}
