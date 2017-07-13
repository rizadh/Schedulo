//
//  SessionDetailViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-13.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class SessionDetailViewController: UITableViewController {
    // MARK: - Private Properties

    private var session: Session
    private let saveHandler: (Session) -> Void

    // MARK: - Private Static Methods

    private static func generateSession() -> Session {
        let startTime = Time(hour: 9, minute: 0)
        let endTime = Time(hour: 10, minute: 30)

        let timeRange = TimeRange(from: startTime, to: endTime)

        return Session(day: .Monday, time: timeRange)
    }

    // MARK: - Private Methods

    @objc
    private func saveAndDismiss() {
        saveHandler(session)
        navigationController?.popViewController(animated: true)
    }

    @objc
    private func cancel() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Initializers

    init(for sessionOrNil: Session?, saveHandler: @escaping (Session) -> Void) {
        let isNewSession: Bool

        if let session = sessionOrNil {
            isNewSession = false
            self.session = session
        } else {
            isNewSession = true
            self.session = SessionDetailViewController.generateSession()
        }

        self.saveHandler = saveHandler

        super.init(style: .grouped)

        let cancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        let saveItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveAndDismiss))

        self.navigationItem.title = isNewSession ? "New Session" : "Edit Session"
        self.navigationItem.leftBarButtonItem = cancelItem
        self.navigationItem.rightBarButtonItem = saveItem
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
