//
//  PlanProvider.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-10-10.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

final class PlanProvider: NSObject {
    let plan: Plan

    init(for plan: Plan) {
        self.plan = plan
    }
}

extension PlanProvider: NSItemProviderWriting {
    static var writableTypeIdentifiersForItemProvider: [String] {
        return ["plan"]
    }

    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        let data = try? JSONEncoder().encode(plan)

        completionHandler(data, nil)

        return nil
    }
}

extension PlanProvider: NSItemProviderReading {
    static var readableTypeIdentifiersForItemProvider: [String] {
        return ["plan"]
    }

    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> PlanProvider {
        let plan = try JSONDecoder().decode(Plan.self, from: data)

        return PlanProvider(for: plan)
    }


}
