//
//  CourseViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-29.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class CourseViewController: UITableViewController, TextFieldCellDelegate {
    let COURSE_INFORMATION_SECTION = 0
    let SECTIONS_SECTION = 1

    var course: Course {
        didSet {
            updateSubviews()
            changeHandler(course)
        }
    }

    var selectedSectionIndex: Int!

    var changeHandler: (Course) -> Void

    let originalCourse: Course

    var sections: [Section] {
        get {
            return course.sections
        }

        set {
            course.sections = newValue
        }
    }

    init (for course: Course, changeHandler: @escaping (Course) -> Void) {
        self.course = course
        self.originalCourse = course
        self.changeHandler = changeHandler

        super.init(style: .grouped)

        updateSubviews()
    }

    @nonobjc
    func valueDidChange(in textFieldCell: TextFieldCell, to newValue: String?) {
        course.code = newValue ?? ""
    }

    lazy var courseCodeField: TextFieldCell = {
        let cell = TextFieldCell()

        cell.textLabel?.text = "Course Code"
        cell.textField.placeholder = "ABC123"
        cell.selectionStyle = .none

        cell.delegate = self

        return cell
    }()

    func updateSubviews() {
        navigationItem.title = course.code.isEmpty ? "New Course" : course.code
        courseCodeField.textField.text = course.code
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    func addNewSection() {
        let newSection = Section(identifier: "", sessions: [])

        self.course.sections.append(newSection)

        tableView.insertRows(at: [IndexPath(row: course.sections.count - 1, section: SECTIONS_SECTION)], with: .automatic)

        editSection(newSection)
    }

    private func editSection(_ section: Section) {
        selectedSectionIndex = sections.index(of: section)
        let controller = SectionViewController(for: section) { [unowned self] section in
            self.sections[self.selectedSectionIndex] = section
            self.selectedSectionIndex = self.sections.index(of: section)
            self.tableView.reloadData()
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case COURSE_INFORMATION_SECTION:
            return "Course Information"
        case SECTIONS_SECTION:
            return "Sections"
        default:
            fatalError("Unrecognized section")
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case COURSE_INFORMATION_SECTION:
            return 1
        case SECTIONS_SECTION:
            return course.sections.count + 1
        default:
            fatalError("Unrecognized section")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case COURSE_INFORMATION_SECTION:
            return courseCodeField
        case SECTIONS_SECTION:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.accessoryType = .disclosureIndicator

            if indexPath.row < course.sections.count {
                let section = sections[indexPath.row]

                if section.identifier.isEmpty {
                    cell.textLabel?.text = "New Section"
                    cell.textLabel?.textColor = .lightGray
                } else {
                    cell.textLabel?.text = section.identifier
                    cell.detailTextLabel?.text = "\(section.sessions.count) session"
                    if section.sessions.count != 1 { cell.detailTextLabel?.text? += "s" }
                }
            } else {
                cell.textLabel?.text = "Add New Section"
            }
            return cell
        default:
            fatalError("Unrecognized section")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == SECTIONS_SECTION else {
            return
        }

        if indexPath.row < course.sections.count {
            editSection(sections[indexPath.row])
        } else {
            addNewSection()
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard indexPath.section == SECTIONS_SECTION else {
            fatalError("Can only delete from sections section")
        }
        
        switch editingStyle {
        case .delete:
            sections.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            fatalError("Unsupported commit operation")
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == SECTIONS_SECTION && indexPath.row < sections.count
    }
}
