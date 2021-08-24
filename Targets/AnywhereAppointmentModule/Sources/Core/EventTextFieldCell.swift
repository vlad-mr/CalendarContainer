//
//  EventTextFieldCell.swift
//  Anytime
//
//  Created by Vignesh on 13/01/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

protocol TextFieldCellDelegate: UITextFieldDelegate {
    func textFieldDidChange(_ sender: UITextField)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    func textFieldDidBeginEditing(_ textField: UITextField)
    func textFieldDidEndEditing(_ textField: UITextField)
}

extension TextFieldCellDelegate {
    func textFieldShouldReturn(_: UITextField) -> Bool {
        return true
    }

    func textFieldDidBeginEditing(_: UITextField) {}

    func textFieldDidEndEditing(_: UITextField) {}
}

class EventTextFieldCell: EventCell {
    @IBOutlet private(set) var textField: UITextField!

    var placeHolderText: String?
    var eventText: String?
    var delegate: TextFieldCellDelegate? {
        didSet {
            textField.delegate = delegate
        }
    }

    var isEnabled: Bool = false {
        didSet {
            toggleCellState(isEnabled: isEnabled)
        }
    }

    var autocorrectionType = UITextAutocorrectionType.default {
        didSet {
            textField.autocorrectionType = autocorrectionType
        }
    }

    var autoCapitalizationType = UITextAutocapitalizationType.words {
        didSet {
            textField.autocapitalizationType = autoCapitalizationType
        }
    }

    var returnKeyType = UIReturnKeyType.next {
        didSet {
            textField.returnKeyType = returnKeyType
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        textField.font = AppDecor.Fonts.medium.withSize(15)
        textField.placeholder = placeHolderText
        textField.text = eventText
        textField.autocapitalizationType = autoCapitalizationType
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.autocorrectionType = autocorrectionType
        textField.returnKeyType = returnKeyType
        separatorInset.right = .greatestFiniteMagnitude
    }

    @objc func textFieldDidChange(_ sender: UITextField) {
        delegate?.textFieldDidChange(sender)
    }

    func configureCell(withPlaceHolder placeholderText: String, icon: UIImage?, shouldShowSeparator: Bool = false, imageSize: CGFloat = 32) {
        textField.placeholder = placeholderText
        if let img = icon {
            iconImageView.image = img
            updateImageSize(to: imageSize)
        }
        separatorView.isHidden = !shouldShowSeparator
    }

    func setText(_ text: String) {
        textField.text = text
    }

    func setIcon(forColorCode code: Int) {
        iconImageView.setImage(forColorCode: code, size: CGSize(width: 32, height: 32))
    }

    private func toggleCellState(isEnabled: Bool) {
        textField.isEnabled = isEnabled
    }
}
