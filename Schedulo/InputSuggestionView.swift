//
//  InputSuggestionView.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-20.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class InputSuggestionView: UIInputView {
    var options: [String] {
        didSet {
            addSubviews()
        }
    }
    var buttons: [UIButton] {
        return options.map { buttonTitle in
            let button = UIButton()

            button.setTitle(buttonTitle, for: .normal)
            button.setTitleColor(UIColor.darkText, for: .normal)
            button.setTitleColor(UIColor.darkText.withAlphaComponent(0.5), for: .highlighted)

            button.backgroundColor = .white
            button.layer.shadowOpacity = 0.1
            button.layer.shadowOffset = CGSize(width: 0, height: 1)
            button.layer.shadowRadius = 1
            button.layer.cornerRadius = 4

            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(optionWasPressed))

            button.addGestureRecognizer(tapRecognizer)
            return button
        }
    }
    private var rootSubview: UIView?
    private let suggestionHandler: (String) -> Void

    init(with options: [String], suggestionHandler: @escaping (String) -> Void) {
        self.suggestionHandler = suggestionHandler
        self.options = options

        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50), inputViewStyle: .default)

        addSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func optionWasPressed(gestureRecognizer: UITapGestureRecognizer) {
        if let selectedOption = (gestureRecognizer.view as? UIButton)?.titleLabel?.text {
            suggestionHandler(selectedOption)
        }
    }

    private func addSubviews() {
        let scrollView = UIScrollView()

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = false

        let stackView = UIStackView(arrangedSubviews: buttons)

        stackView.distribution = .fillProportionally
        stackView.spacing = 8

        self.rootSubview = stackView

        if let existingRootSubview = self.rootSubview {
            existingRootSubview.removeFromSuperview()
        }

        scrollView.addSubview(stackView)
        self.addSubview(scrollView)

        scrollView.frame = CGRect(x: 8, y: 8, width: self.bounds.width - 16, height: self.bounds.height - 16)

        let totalWidth = buttons.map({button in 32 + button.intrinsicContentSize.width}).reduce(0, +)
        let targetWidth = max(scrollView.bounds.width, totalWidth)
        stackView.frame = CGRect(x: 0, y: 0, width: targetWidth, height: scrollView.bounds.height)
        scrollView.contentSize = stackView.frame.size

        print(scrollView.contentSize)
    }
}
