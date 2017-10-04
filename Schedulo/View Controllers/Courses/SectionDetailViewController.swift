//
//  SectionDetailViewController.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-10-03.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class SectionDetailViewController: UITableViewController {
    var stateController: StateController!
    var courseIndex: Int!
    var sectionIndex: Int!

    private var section: Section {
        get {
            return stateController.courses[courseIndex].sections[sectionIndex]
        }

        set {
            stateController.courses[courseIndex].sections[sectionIndex] = newValue
        }
    }

    override func viewDidLoad() {
        title = "Section"
    }
}
