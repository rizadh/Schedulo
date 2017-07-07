//
//  AppState.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-30.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation
import os

class StateController {
    private struct State: Codable {
        var courses = [Course]()
    }

    private var state: State {
        didSet {
            StateController.savedState = state
        }
    }

    private static var savedState: State {
        set {
            guard let jsonData = try? JSONEncoder().encode(newValue) else {
                if #available(iOS 10.0, *) {
                    os_log("Could not save application state", log: .default, type: .error)
                } else {
                    NSLog("Could not save application state")
                }
                return
            }

            UserDefaults.standard.setValue(jsonData, forKeyPath: "state")
        }

        get {
            guard let stateData = UserDefaults.standard.data(forKey: "state") else {
                return State()
            }

            guard let savedState = try? JSONDecoder().decode(State.self, from: stateData) else {
                return State()
            }

            return savedState
        }
    }

    var courses: [Course] {
        return state.courses
    }

    init() {
        state = StateController.savedState
    }

    func add(_ course: Course) {
        state.courses.append(course)
    }

    func removeCourse(at index: Int) {
        state.courses.remove(at: index)
    }

    func replaceCourse(at index: Int, with course: Course) {
        state.courses[index] = course
    }
}
