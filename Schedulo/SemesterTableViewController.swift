//
//  SemesterTableViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-23.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class SemesterTableViewController: UITableViewController {
    var semesters = [Semester]()
    var selectedSemesterIndex: Int!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Semesters"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addSemester))
        navigationItem.leftBarButtonItem = editButtonItem
    }

    func addSemester() {
        let (year, season) = getCurrentSeasonAndYear()
        semesters.append(Semester(year: year, season: season))

        let indexPath = IndexPath(row: semesters.count - 1, section: 0)

        tableView.insertRows(at: [indexPath], with: .automatic)

        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        tableView(tableView, didSelectRowAt: indexPath)
    }

    func finishedEditing(_ semester: Semester) {
        semesters[selectedSemesterIndex] = semester
        tableView.reloadData()
    }

    private func getCurrentSeasonAndYear() -> (year: Int, season: Season) {
        let date = Date()
        let calender = Calendar.current
        let month = calender.component(.month, from: date)
        let year = calender.component(.year, from: date)

        switch (month) {
        case 9...12:
            return (year: year, season: .Fall)
        case 1...4:
            return (year: year, season: .Winter)
        case 5...8:
            return (year: year, season: .Summer)
        default:
            fatalError("Could not recognize month")
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return semesters.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let scheduleCell = UITableViewCell(style: .value1, reuseIdentifier: nil)

        scheduleCell.accessoryType = .disclosureIndicator
        scheduleCell.showsReorderControl = true

        let semester = semesters[indexPath.row]
        let courseCount = semester.courses.count
        scheduleCell.textLabel?.text = "\(semester)"
        scheduleCell.detailTextLabel?.text = "\(courseCount) course"
        if courseCount != 1 { scheduleCell.detailTextLabel?.text? += "s" }

        return scheduleCell
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingSemester = semesters.remove(at: sourceIndexPath.row)
        semesters.insert(movingSemester, at: destinationIndexPath.row)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            semesters.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            fatalError("Unrecognized commit")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSemesterIndex = indexPath.row
        navigationController?.pushViewController(SemesterViewController(for: semesters[indexPath.row]), animated: true)
    }
}

