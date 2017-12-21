//
//  PlanListViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-12-14.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit
import CoreData

class SemesterListViewController: UITableViewController {
    private lazy var viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private lazy var resultsController: NSFetchedResultsController<Semester> = createResultsController()

    convenience init() {
        self.init(style: .plain)

        title = "Semesters"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSemester))
    }
}

// MARK: - Semester Management
extension SemesterListViewController {
    private func createResultsController() -> NSFetchedResultsController<Semester> {
        let fetchRequest: NSFetchRequest = Semester.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "year", ascending: true),
            NSSortDescriptor(key: "season", ascending: true),
        ]

        let fetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: "plans")

        fetchController.delegate = self
        try! fetchController.performFetch()

        return fetchController
    }

    private static func name(from textField: UITextField) -> String? {
        let name = textField.text!.trimmingCharacters(in: .whitespaces)

        guard !name.isEmpty else { return nil }

        return name
    }

    @objc private func addSemester() {
        let semesterViewController = SemesterViewController(semester: nil)
        let navigationController = UINavigationController(rootViewController: semesterViewController)

        present(navigationController, animated: true, completion: nil)
    }
}

// MARK: - NSFetchedResultsControllerDelegate Conformance
extension SemesterListViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections([sectionIndex], with: .automatic)
        case .delete:
            tableView.deleteSections([sectionIndex], with: .automatic)
        default:
            fatalError("Unrecognized change type: \(type)")
        }
    }
}

// MARK: - UITableViewController Overrides
extension SemesterListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return resultsController.sections!.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return resultsController.sections![section].indexTitle ?? ""
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController.sections![section].numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let semester = resultsController.object(at: indexPath)

        cell.textLabel!.text = semester.description
        cell.accessoryType = .detailDisclosureButton

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard case .delete = editingStyle else {
            return
        }

        let semester = resultsController.object(at: indexPath)

        viewContext.delete(semester)

        try! viewContext.save()
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let semester = resultsController.object(at: indexPath)
        let semesterViewController = SemesterViewController(semester: semester)
        let navigationController = UINavigationController(rootViewController: semesterViewController)

        present(navigationController, animated: true, completion: nil)
    }
}
