//
//  SectionsViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-26.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class SectionsViewController: UITableViewController {
    // MARK: - Private Properties
    private let saveHandler: (Groupable<String, [Section]>) -> Void
    private var sections: Groupable<String, [Section]> {
        didSet {
            saveHandler(sections)
        }
    }

    init(for sections: Groupable<String, [Section]>, saveHandler: @escaping (Groupable<String, [Section]>) -> Void) {
        self.saveHandler = saveHandler
        self.sections = sections

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
        switch sections {
        case .ungrouped:
            return 2
        case .grouped(let groups):
            return 1 + groups.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}
