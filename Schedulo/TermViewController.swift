//
//  TermViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-24.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class TermViewController: UITableViewController {
    let TERM_SECTION = 0
    let COURSES_SECTION = 1

    let YEAR_ROW = 0
    let SEASON_ROW = 1
    let LABEL_ROW = 2

    var term: Term {
        didSet {
            updateSubviews()
        }
    }

    var originalTerm: Term

    lazy var yearPicker: StepperCell = {
        let cell = StepperCell()

        cell.textLabel?.text = "Year"
        cell.stepper.minimumValue = 0
        cell.stepper.maximumValue = Double.infinity
        cell.selectionStyle = .none

        cell.delegate = self

        return cell
    }()

    lazy var seasonPicker: SegmentedControlCell = {
        let cell = SegmentedControlCell()

        cell.textLabel?.text = "Season"
        cell.selectionStyle = .none

        for (index, season) in Season.all.enumerated() {
            cell.control.insertSegment(withTitle: season.rawValue, at: index, animated: false)
        }

        cell.delegate = self

        return cell
    }()

    lazy var labelEditor: TextFieldCell = {
        let cell = TextFieldCell()

        cell.textLabel?.text = "Label"
        cell.textField.placeholder = "Optional"
        cell.selectionStyle = .none

        cell.delegate = self

        return cell
    }()

    init(for term: Term) {
        self.term = term
        self.originalTerm = term

        super.init(style: .grouped)

        updateSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    private func updateSubviews() {
        seasonPicker.control.selectedSegmentIndex = Season.all.index(of: term.season)!
        labelEditor.textField.text = term.label
        yearPicker.value = term.year

        navigationItem.title = term.description
    }

    func cancelEdit() {
        term = originalTerm
        navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .groupTableViewBackground

        navigationItem.title = term.description
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelEdit))
    }

    override func viewWillDisappear(_ animated: Bool) {
        guard let controller = navigationController?.viewControllers.first as? TermTableViewController else {
            fatalError("Could not access TermTableViewController")
        }

        controller.finishedEditing(term)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case TERM_SECTION:
            return "Term Information"
        case COURSES_SECTION:
            return "Courses"
        default:
            fatalError("Unrecognized section")
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case TERM_SECTION:
            return 3
        case COURSES_SECTION:
            return term.courses.count
        default:
            fatalError("Unrecognized section")
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case TERM_SECTION:
            switch indexPath.row {
                case YEAR_ROW:
                    return yearPicker
                case SEASON_ROW:
                    return seasonPicker
                case LABEL_ROW:
                    return labelEditor
                default:
                    fatalError("Unrecognized row")
            }
        case COURSES_SECTION:
            let cell = UITableViewCell()
            cell.textLabel?.text = Array(term.courses)[indexPath.row].code
            return cell
        default:
            fatalError("Unrecognized section")
        }
    }
}

extension TermViewController: TextFieldCellDelegate {
    @nonobjc
    func valueDidChange(in textFieldCell: TextFieldCell, to newValue: String?) {
        term.label = newValue
    }
}

extension TermViewController: StepperCellDelegate {
    @nonobjc
    func valueDidChange(in stepperCell: StepperCell, to newValue: Double) {
        term.year = Int(newValue)
    }
}

extension TermViewController: SegmentedControlCellDelegate {
    @nonobjc
    func valueDidChange(in segmentedControlCell: SegmentedControlCell, to newValue: Int) {
        term.season = Season.all[newValue]
    }
}
