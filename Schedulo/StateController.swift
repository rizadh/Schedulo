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
        var schedules = [Schedule]()
    }

    private var state = State() {
        didSet {
            StateController.savedState = state
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

    var schedules: [Schedule] {
        get {
            return state.schedules
        }

        set {
            state.schedules = newValue
        }
    }

    init() {
        state = StateController.savedState ?? State()
    }

    func add(_ course: Course) {
        state.courses.append(course)
    }

    func add(_ course: Course, at index: Int) {
        state.courses.insert(course, at: index)
    }

    func add(_ schedule: Schedule) {
        state.schedules.append(schedule)
    }

    func add(_ schedule: Schedule, at index: Int) {
        state.schedules.insert(schedule, at: index)
    }

    func removeCourse(at index: Int) {
        state.courses.remove(at: index)
    }

    func removeSchedule(at index: Int) {
        state.schedules.remove(at: index)
    }

    func replaceCourse(at index: Int, with course: Course) {
        state.courses[index] = course
    }

    func replaceSchedule(at index: Int, with schedule: Schedule) {
        state.schedules[index] = schedule
    }
}
