//
//  SegmentedControlCell.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-06-27.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

protocol SegmentedControlCellDelegate {
    func valueDidChange(in stepperCell: SegmentedControlCell, to newValue: Int)
}

class SegmentedControlCell: UITableViewCell {
    var delegate: SegmentedControlCellDelegate?

    lazy var control: UISegmentedControl = {
        let control = UISegmentedControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(self.handleChange), for: .valueChanged)
        return control
    }()

    func handleChange() {
        delegate?.valueDidChange(in: self, to: control.selectedSegmentIndex)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.addSubview(control)

        let guide = contentView.layoutMarginsGuide

        control.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        control.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
    }
}
