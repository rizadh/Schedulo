//
//  AppState.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-30.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

class StateController {
    private(set) var courses = [Course]()

    func add(_ course: Course) {
        courses.append(course)
    }

    func removeCourse(at index: Int) {
        courses.remove(at: index)
    }

    func replaceCourse(at index: Int, with course: Course) {
        courses[index] = course
    }
}
