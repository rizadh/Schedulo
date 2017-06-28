//
//  ViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-23.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class TermTableViewController: UITableViewController {
    var terms = [Term]()
    var selectedTermIndex: Int!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Terms"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addTerm))
        navigationItem.leftBarButtonItem = editButtonItem
    }

    func addTerm() {
        let (year, season) = getCurrentSeasonAndYear()
        terms.append(Term(year: year, season: season))

        let indexPath = IndexPath(row: terms.count - 1, section: 0)

        tableView.insertRows(at: [indexPath], with: .automatic)

        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        tableView(tableView, didSelectRowAt: indexPath)
    }

    func finishedEditing(_ term: Term) {
        terms[selectedTermIndex] = term
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
        return terms.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let scheduleCell = UITableViewCell(style: .value1, reuseIdentifier: nil)

        scheduleCell.accessoryType = .disclosureIndicator
        scheduleCell.showsReorderControl = true

        let term = terms[indexPath.row]
        let courseCount = term.courses.count
        scheduleCell.textLabel?.text = "\(term)"
        scheduleCell.detailTextLabel?.text = "\(courseCount) course"
        if courseCount != 1 { scheduleCell.detailTextLabel?.text? += "s" }

        return scheduleCell
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingTerm = terms.remove(at: sourceIndexPath.row)
        terms.insert(movingTerm, at: destinationIndexPath.row)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            terms.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            fatalError("Unrecognized commit")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTermIndex = indexPath.row
        navigationController?.pushViewController(TermViewController(for: terms[indexPath.row]), animated: true)
    }
}

