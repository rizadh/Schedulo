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
    private struct UserDefaultsConstants {
        static let key = "state"

        private init() { }
    }


    private struct State: Codable {
        var courses = [Course]()
        var schedules = [Schedule]()
    }

    private var state = State() {
        didSet {
            StateController.savedState = state
        }
    }

    private static var savedState: State {
        get {
            guard let stateData = UserDefaults.standard.data(forKey: UserDefaultsConstants.key) else {
                return State()
            }

            guard let savedState = try? JSONDecoder().decode(State.self, from: stateData) else {
                return State()
            }

            return savedState
        }

        set {
            guard let jsonData = try? JSONEncoder().encode(newValue) else {
                let message: StaticString = "Could not save application state"

                if #available(iOS 10.0, *) {
                    os_log(message, log: .default, type: .error)
                } else {
                    NSLog(message.description)
                }
                return
            }

            UserDefaults.standard.setValue(jsonData, forKeyPath: UserDefaultsConstants.key)
        }
    }

    var courses: [Course] {
        return state.courses
    }

    var schedules: [Schedule] {
        return state.schedules
    }

    init() {
        state = StateController.savedState
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
