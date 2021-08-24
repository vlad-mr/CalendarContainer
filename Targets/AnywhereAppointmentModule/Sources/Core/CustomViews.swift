//
//  CustomViews.swift
//  Anytime
//
//  Created by Vignesh on 11/01/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit.UIView

class RoundedView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = frame.height / 2
    }
}

class StatefulButton: UIButton {
    enum Mode {
        case selected
        case unselected
    }

    var mode: Mode = .unselected {
        didSet {
            setupView()
        }
    }

    var buttonColor: UIColor?

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let value = isEnabled
        isEnabled = value
    }

    func configure(selectedModeTitle: String, unselectedModeTitle: String, color: UIColor? = AppDecor.MainColors.anytimeSolidBlue, mode: Mode = .unselected, icon: UIImage? = nil) {
        buttonColor = color
        self.mode = mode
        setTitle(selectedModeTitle, for: .disabled)
        setTitle(unselectedModeTitle, for: .normal)
        setupView()
        setIcon(icon: icon)
    }

    func setIcon(icon: UIImage?) {
        setImage(icon, for: .disabled)
        semanticContentAttribute = .forceRightToLeft
    }

    func setupView() {
        switch mode {
        case .selected:
            isEnabled = false
            backgroundColor = buttonColor?.withAlphaComponent(0.5)
        case .unselected:
            isEnabled = true
            backgroundColor = buttonColor
        }
    }
}

class RoundedButton: AnytimeButton {
    enum Action {
        case edit(title: String = "Edit")
        case delete(title: String = "Delete")
        case custom(title: String, bgColor: UIColor?, textColor: UIColor?)

        var title: String {
            switch self {
            case let .edit(title):
                return title
            case let .delete(title):
                return title
            case let .custom(title, _, _):
                return title
            }
        }
    }

    var bgColor: UIColor = .gray {
        didSet {
            self.backgroundColor = bgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layer.cornerRadius = 10
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        backgroundColor = UIColor(red: 150, green: 150, blue: 150).withAlphaComponent(0.7)
        isEnabled = false
        bgColor = AppDecor.MainColors.anytimeLightBlue
    }

    // Due the issue in iOS 12 we are overriding the layoutSubviews method to change the color
    override func layoutSubviews() {
        super.layoutSubviews()
        let value = isEnabled
        isEnabled = value
    }

    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? bgColor : UIColor(red: 150, green: 150, blue: 150).withAlphaComponent(0.7)
        }
    }

    func configureButton(withTitle title: String, backgroundColor: UIColor?, textColor: UIColor?, fontSize size: CGFloat, shouldDropShadow: Bool = false, shouldShowBorder: Bool = false) {
        setTitle(title, for: .normal)
        setTitleColor(textColor, for: .normal)
        titleLabel?.font = AppDecor.Fonts.medium.withSize(size)
        bgColor = backgroundColor ?? .white
        if shouldShowBorder {
            setBorder()
        }

        if shouldDropShadow {
            dropShadow()
        }
    }

    private func setBorder() {
        layer.borderColor = AppDecor.BorderColors.whiteBorder.cgColor
        layer.borderWidth = 1
    }

    func setup(forAction action: Action) {
        switch action {
        case .edit:
            setTitleColor(AppDecor.MainColors.anytimeSolidBlue, for: .normal)
        case .delete:
            setTitleColor(AppDecor.CardColors.sun, for: .normal)
        case let .custom(_, bgColor, textColor):
            setTitleColor(textColor, for: .normal)
            self.bgColor = bgColor ?? .blue
        }
    }
}

extension RoundedButton {
    static func getButton(forAction action: Action, target: Any?, handler: Selector?, frame: CGRect = CGRect()) -> RoundedButton {
        let button = RoundedButton()
        button.configureButton(withTitle: action.title, backgroundColor: .white, textColor: .black, fontSize: 15, shouldDropShadow: true, shouldShowBorder: true)
        let spacing: CGFloat = 20
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: spacing, bottom: 5, right: spacing)
        if let handler = handler {
            button.addTarget(target, action: handler, for: .touchUpInside)
        }
        button.frame = frame
        button.setup(forAction: action)
        return button
    }
}

class ShareButton: UIButton {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        titleLabel?.font = AppDecor.Fonts.medium.withSize(13)
        layer.borderColor = AppDecor.BorderColors.whiteBorder.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.withAlphaComponent(0.7).cgColor
        layer.shadowRadius = 2
        startAnimatingPressActions()
    }
}

class AnytimeButton: UIButton {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        startAnimatingPressActions()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        startAnimatingPressActions()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        startAnimatingPressActions()
    }
}

class LoginButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        initializeButton()
        addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeButton()
    }

    var actionForButton: ((UIButton) -> Void)?

    private var imageHeightConstraint: NSLayoutConstraint!
    private var imageWidthConstraint: NSLayoutConstraint!
    private var titleLeadingConstraint: NSLayoutConstraint!
    private var titleTrailingConstraint: NSLayoutConstraint!
    private var imageLeadingConstraint: NSLayoutConstraint!

    private func initializeButton() {
        titleLabel?.font = AppDecor.Fonts.H3
        titleLabel?.textColor = UIColor.black.withAlphaComponent(0.9)
        layer.borderColor = AppDecor.BorderColors.whiteBorder.cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 8
        titleLabel?.textAlignment = .center

        setConstraints()
        dropShadow()
        startAnimatingPressActions()
    }

    private func setConstraints() {
        imageLeadingConstraint = imageView?.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
        imageWidthConstraint = imageView?.widthAnchor.constraint(equalToConstant: 30)
        imageHeightConstraint = imageView?.heightAnchor.constraint(equalToConstant: 30)
        titleLeadingConstraint = titleLabel?.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20 + 30)
        titleTrailingConstraint = titleLabel?.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        imageView?.clipsToBounds = true
        NSLayoutConstraint.activate([imageHeightConstraint, imageWidthConstraint, imageLeadingConstraint, titleTrailingConstraint, titleLeadingConstraint])
    }

    private func setSizeConstraints(_ size: CGFloat) {
        imageWidthConstraint.constant = size
        imageHeightConstraint.constant = size

        titleLeadingConstraint.constant = 20 + size
        titleTrailingConstraint.constant = -20
    }

    func configureButton(withIcon icon: UIImage?, title: String, imageSize: CGFloat) {
        setTitle(title, for: .normal)
        setImage(icon, for: .normal)
        setSizeConstraints(imageSize)
    }

    @objc func didTapButton(_ sender: UIButton) {
        actionForButton?(sender)
    }
}

extension UIButton {
    func startAnimatingPressActions() {
        addTarget(self, action: #selector(animateDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(animateUp), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
    }

    @objc private func animateDown(sender: UIButton) {
        animate(sender, transform: CGAffineTransform.identity.scaledBy(x: 0.95, y: 0.95))
    }

    @objc private func animateUp(sender: UIButton) {
        animate(sender, transform: .identity)
    }

    private func animate(_ button: UIButton, transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 3,
                       options: [.curveEaseInOut],
                       animations: {
                           button.transform = transform
                       }, completion: nil)
    }
}
