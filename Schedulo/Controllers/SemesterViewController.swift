//
//  SemesterViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-12-19.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit
import CoreData

private extension Selector {
    static let cancelTapped = #selector(SemesterViewController.cancelTapped)
    static let saveTapped = #selector(SemesterViewController.saveTapped)
}

class SemesterViewController: UIViewController {
    private let context: NSManagedObjectContext
    private var semester: Semester

    init(semester semesterOrNil: Semester?) {
        let parentContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let temporaryContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        context = temporaryContext
        context.parent = parentContext
        semester = semesterOrNil ?? SemesterViewController.createSemester(in: temporaryContext)

        super.init(nibName: nil, bundle: nil)

        title = semesterOrNil == nil ? "New Semester" : "Edit Semester"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: .cancelTapped)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: .saveTapped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func createSemester(in context: NSManagedObjectContext) -> Semester {
        let semester = Semester(context: context)
        let date = Date()
        let calendar = Calendar(identifier: .gregorian)
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let seasonIndex = Int((month - 1) / 4)
        let season = SemesterViewController.indexToSeason[seasonIndex]

        semester.season = season
        semester.year = Int16(year)

        return semester
    }

    @objc func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc func saveTapped() {
        try! context.save()
        try! context.parent!.save()

        dismiss(animated: true, completion: nil)
    }

    private func updateSaveButton() {
        navigationItem.rightBarButtonItem?.isEnabled = !semesterIsDuplicate()
    }

    private func semesterIsDuplicate() -> Bool {
        let fetchRequest: NSFetchRequest<Semester> = Semester.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "year == \(semester.year)"),
            NSPredicate(format: "season == \"\(semester.season!)\""),
        ])

        return try! context.count(for: fetchRequest) > 1
    }
}

// MARK: - UIViewController Overrides
extension SemesterViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false

        picker.dataSource = self
        picker.delegate = self

        view.addSubview(picker)

        picker.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        picker.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        picker.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor).isActive = true
        picker.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor).isActive = true

        // Setup picker selections

        let season = semester.season!
        let year = semester.year

        let seasonRow = SemesterViewController.seasonToIndex[season]!

        picker.selectRow(seasonRow, inComponent: 0, animated: false)
        picker.selectRow(Int(year), inComponent: 1, animated: false)

        updateSaveButton()
    }
}

// MARK: - UIPickerViewDataSource Conformance
extension SemesterViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? 3 : Int(Int16.max)
    }
}

// MARK: - UIPickerViewDelegate Conformance
extension SemesterViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return SemesterViewController.indexToSeason[row]
        } else {
            return row.description
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            semester.season = SemesterViewController.indexToSeason[row]
        } else {
            semester.year = Int16(row)
        }

        updateSaveButton()
    }
}

// MARK: Season Helper Methods
extension SemesterViewController {
    private static let seasonToIndex: [String: Int] = [
        "Winter": 0,
        "Summer": 1,
        "Fall": 2,
    ]

    private static let indexToSeason: [Int: String] = [
        0: "Winter",
        1: "Summer",
        2: "Fall",
    ]
}
