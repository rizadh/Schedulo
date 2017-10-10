//
//  CourseProvider.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-10-10.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

final class CourseProvider: NSObject {
    let course: Course

    init(for course: Course) {
        self.course = course
    }
}

extension CourseProvider: NSItemProviderWriting {
    static var writableTypeIdentifiersForItemProvider: [String] {
        return ["course"]
    }

    @available(iOS 11.0, *)
    static func itemProviderVisibilityForRepresentation(withTypeIdentifier typeIdentifier: String) -> NSItemProviderRepresentationVisibility {
        return .ownProcess
    }

    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        let courseData = try? JSONEncoder().encode(course)

        completionHandler(courseData, nil)

        return nil
    }
}

extension CourseProvider: NSItemProviderReading {
    static var readableTypeIdentifiersForItemProvider: [String] {
        return ["course"]
    }

    @available(iOS 11.0, *)
    func itemProviderVisibilityForRepresentation(withTypeIdentifier typeIdentifier: String) -> NSItemProviderRepresentationVisibility {
        return .ownProcess
    }

    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> CourseProvider {
        let course = try JSONDecoder().decode(Course.self, from: data)

        return CourseProvider(for: course)
    }
}
