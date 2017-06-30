//
//  SemesterTableViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-23.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class SemesterTableViewController: UITableViewController {
    var semesters = [Semester]() {
        didSet {
            semesters.sort()
            semesters.reverse()
        }
    }
    var selectedSemesterIndex: Int!

    var semestersGroupedByEffectiveYear: [(year: Int, semesters: [Semester])] {
        var groupedSemesters = [(year: Int, semesters: [Semester])]()

        for semester in semesters {
            let year = semester.effectiveYear

            if year == groupedSemesters.last?.year {
                groupedSemesters[groupedSemesters.count - 1].semesters.append(semester)
            } else {
                groupedSemesters.append((year, [semester]))
            }
        }

        return groupedSemesters
    }

    init() {
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Semesters"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addNewSemester))
        navigationItem.leftBarButtonItem = editButtonItem
    }

    func addNewSemester() {
        let (year, season) = getCurrentSeasonAndYear()

        let newSemester = Semester(year: year, season: season)

        semesters.append(newSemester)

        guard let semesterIndexPath = indexPath(of: newSemester) else {
            fatalError("Could not find semester's index path")
        }

        tableView.beginUpdates()
        if semestersGroupedByEffectiveYear.count > tableView.numberOfSections {
            tableView.insertSections(IndexSet(integer: semesterIndexPath.section), with: .fade)
        }
        tableView.insertRows(at: [semesterIndexPath], with: .automatic)
        tableView.endUpdates()
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

    private func semester(at indexPath: IndexPath) -> Semester {
        return semestersGroupedByEffectiveYear[indexPath.section].semesters[indexPath.row]
    }

    private func indexPath(of semester: Semester) -> IndexPath? {
        var lastMatch: IndexPath?

        for (section, group) in semestersGroupedByEffectiveYear.enumerated() {
            for (row, currentSemester) in group.semesters.enumerated() {
                if (currentSemester == semester) {
                    lastMatch = IndexPath(row: row, section: section)
                }
            }
        }

        return lastMatch
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return semestersGroupedByEffectiveYear[section].semesters.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let scheduleCell = UITableViewCell(style: .value1, reuseIdentifier: nil)

        scheduleCell.accessoryType = .disclosureIndicator

        let targetSemester = semester(at: indexPath)
        let courseCount = targetSemester.courses.count
        scheduleCell.textLabel?.text = "\(targetSemester)"
        scheduleCell.detailTextLabel?.text = "\(courseCount) course"
        if courseCount != 1 { scheduleCell.detailTextLabel?.text? += "s" }

        return scheduleCell
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let needToRemoveSection = semestersGroupedByEffectiveYear[indexPath.section].semesters.count == 1

            guard let index = semesters.index(of: semester(at: indexPath)) else {
                fatalError("Could not find semester")
            }
            semesters.remove(at: index)

            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if needToRemoveSection {
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
            }
            tableView.endUpdates()
        default:
            fatalError("Unrecognized commit")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSemester = semester(at: indexPath)

        selectedSemesterIndex = semesters.index(of: selectedSemester)
        navigationController?.pushViewController(SemesterViewController(for: selectedSemester) { [unowned self] semester in
            self.semesters[self.selectedSemesterIndex] = semester
            self.selectedSemesterIndex = self.semesters.index(of: semester)
            self.tableView.reloadData()
        }, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return semestersGroupedByEffectiveYear.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let year = semestersGroupedByEffectiveYear[section].year

        return "\(year) - \(year + 1)"
    }
}

