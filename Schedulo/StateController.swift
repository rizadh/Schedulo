//
//  StateController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-30.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation
import os

class StateController {
    private static let userDefaultsKey = "state"

    private struct State: Codable {
        var courses = [Course]()
        var plans = [Plan]()
    }

    private var state = State() {
        didSet {
            DispatchQueue.global(qos: .background).async { [weak self] in
                StateController.savedState = self?.state
            }
        }
    }

    private static var savedState: State? {
        get {
            guard let stateData = UserDefaults.standard.data(forKey: userDefaultsKey) else {
                return nil
            }

            guard let savedState = try? JSONDecoder().decode(State.self, from: stateData) else {
                return nil
            }

            return savedState
        }

        set {
            guard newValue != nil else {
                UserDefaults.standard.removeObject(forKey: userDefaultsKey)
                return
            }

            guard let jsonData = try? JSONEncoder().encode(newValue) else {
                let message: StaticString = "Could not save application state"

                if #available(iOS 10.0, *) {
                    os_log(message, log: .default, type: .error)
                } else {
                    NSLog(message.description)
                }

                return
            }

            UserDefaults.standard.setValue(jsonData, forKeyPath: userDefaultsKey)
        }
    }

    var courses: [Course] {
        get {
            return state.courses
        }

        set {
            state.courses = newValue
        }
    }

    var plans: [Plan] {
        get {
            return state.plans
        }

        set {
            state.plans = newValue
        }
    }

    init() {
        state = StateController.savedState ?? State()
    }
}
