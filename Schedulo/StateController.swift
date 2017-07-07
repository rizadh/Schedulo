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
    private struct State: Codable {
        var courses = [Course]()
    }

    private var stateChain = [State]() {
        didSet {
            StateController.savedStateChain = stateChain

            let notification = Notification(name: Notification.Name(rawValue: "stateDidChange"))
            NotificationCenter.default.post(notification)
        }
    }

    private var state: State {
        get {
            return stateChain.last ?? State()
        }

        set {
            stateChain.append(newValue)
        }
    }

    private static var savedStateChain: [State] {
        get {
            guard let stateChainData = UserDefaults.standard.data(forKey: "stateChain") else {
                return [State]()
            }

            guard let savedStateChain = try? JSONDecoder().decode([State].self, from: stateChainData) else {
                return [State]()
            }

            return savedStateChain
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

            UserDefaults.standard.setValue(jsonData, forKeyPath: "stateChain")
        }
    }

    var courses: [Course] {
        return state.courses
    }

    var isFirstState: Bool {
        return stateChain.count == 0
    }

    init() {
        stateChain = StateController.savedStateChain
    }

    func revertState() {
        stateChain.removeLast()
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
