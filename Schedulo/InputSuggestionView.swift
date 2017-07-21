//
//  InputSuggestionView.swift
//  Schedulo
//
//  Created by Rizadh Nizam on 2017-07-20.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import UIKit

class InputSuggestionView: UIInputView {
    private let options: [String]
    private let suggestionHandler: (String) -> Void

    init(with options: [String], suggestionHandler: @escaping (String) -> Void) {
        self.suggestionHandler = suggestionHandler
        self.options = options

        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 54), inputViewStyle: .default)

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
        // Create buttons
        let buttons: [UIButton] = options.map { buttonTitle in
            let button = UIButton()

            button.setTitle(buttonTitle, for: .normal)
            button.setTitleColor(UIColor.darkText, for: .normal)
            button.setTitleColor(UIColor.darkText.withAlphaComponent(0.5), for: .highlighted)

            button.backgroundColor = .white
            button.layer.cornerRadius = 4
            button.layer.shadowOffset = CGSize(width: 0, height: 1)
            button.layer.shadowOpacity = 0.25
            button.layer.shadowRadius = 0

            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(optionWasPressed))

            button.addGestureRecognizer(tapRecognizer)
            return button
        }

        // Create and configure UIScrollView
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true

        // Create and configure UIStackView
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.distribution = .fillProportionally
        stackView.spacing = 6

        // Add UIScrollView as subview
        self.addSubview(scrollView)
        scrollView.frame = self.bounds

        // Add UIStackView as subview
        scrollView.addSubview(stackView)
        let totalWidth = buttons.map({ button in 18 + button.intrinsicContentSize.width }).reduce(0, +)
        stackView.frame = CGRect(x: 3, y: 12, width: totalWidth, height: scrollView.bounds.height - 16)
        scrollView.contentSize = CGSize(width: stackView.bounds.width + 6, height: stackView.bounds.height)

        // Center suggestions if extra space is present
        if scrollView.contentSize.width < self.bounds.width {
            let padding = (self.bounds.width - totalWidth) / 2

            stackView.frame = CGRect(x: padding, y: 12, width: totalWidth, height: scrollView.bounds.height - 16)
            scrollView.contentSize = CGSize(width: stackView.bounds.width + 2 * padding, height: stackView.bounds.height)
        }

        let gradient = CAGradientLayer()
        gradient.frame = scrollView.bounds
        gradient.startPoint = CGPoint(x: 0.8, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)

        scrollView.layer.mask = gradient

        scrollView.delegate = self
        scrollViewDidScroll(scrollView)
    }
}

extension InputSuggestionView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let mask = scrollView.layer.mask as? CAGradientLayer else {
            return
        }

        let newX = scrollView.layer.position.x + scrollView.contentOffset.x
        let newY = scrollView.layer.position.y + scrollView.contentOffset.y

        let distanceToEnd = scrollView.contentSize.width - (scrollView.contentOffset.x + scrollView.bounds.width)

        var maskStrength: CGFloat = 1
        let fadeWidth: CGFloat = 10

        if distanceToEnd < fadeWidth {
            maskStrength = CGFloat(max(distanceToEnd, 0)) / fadeWidth
        }

        let maskOpacity = 1 - maskStrength

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        mask.colors = [UIColor.black.cgColor, UIColor.black.withAlphaComponent(maskOpacity).cgColor]
        mask.position = CGPoint(x: newX, y: newY)
        CATransaction.commit()
    }
}
