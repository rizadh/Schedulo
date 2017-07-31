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
        return state.courses
    }

    var plans: [Plan] {
        return state.plans
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

    func add(_ plan: Plan) {
        state.plans.append(plan)
    }

    func add(_ plan: Plan, at index: Int) {
        state.plans.insert(plan, at: index)
    }

    func removeCourse(at index: Int) {
        state.courses.remove(at: index)
    }

    func removePlan(at index: Int) {
        state.plans.remove(at: index)
    }

    func replaceCourse(at index: Int, with course: Course) {
        state.courses[index] = course
    }

    func replacePlan(at index: Int, with plan: Plan) {
        state.plans[index] = plan
    }
}
