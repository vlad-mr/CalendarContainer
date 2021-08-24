//
//  TextViewCell.swift
//  Anytime
//
//  Created by Vignesh on 06/03/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

class TextViewCell: EventCell, NibLoadable {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet private weak var placeholderLabel: UILabel!
    
    weak var textViewDelegate: UITextViewDelegate?
    
    var isEnabled: Bool = true
    
    var autocorrectionType = UITextAutocorrectionType.default {
        didSet {
            textView.autocorrectionType = autocorrectionType
        }
    }
    var autoCapitalizationType = UITextAutocapitalizationType.sentences {
        didSet {
            textView.autocapitalizationType = autoCapitalizationType
        }
    }
    var returnKeyType = UIReturnKeyType.default {
        didSet {
            textView.returnKeyType = returnKeyType
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.autocapitalizationType = .sentences
        textView.font = AppDecor.Fonts.medium.withSize(15)
        textView.autocapitalizationType = autoCapitalizationType
        textView.autocorrectionType = autocorrectionType
        textView.returnKeyType = returnKeyType
        textView.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapTextView))
        textView.addGestureRecognizer(tapGestureRecognizer)
        
        placeholderLabel.font = AppDecor.Fonts.medium.withSize(15)
        placeholderLabel.textColor = UIColor(red: 150, green: 150, blue: 150)
    }
    
    @objc func didTapTextView() {
        guard isEnabled else {
            return
        }
        textView.isEditable = true
        textView.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    func configureCell(withPlaceHolder placeholderText: String, icon: UIImage?, shouldShowSeparator: Bool = false) {
        
        placeholderLabel.text = placeholderText
        //        separatorView.isHidden = !shouldShowSeparator
        iconImageView.image = icon
        separatorView.isHidden = !shouldShowSeparator
    }
    
    func setText(_ text: String) {
        textView.text = text
        placeholderLabel.isHidden = text.isNotEmpty
    }
}

extension TextViewCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewDelegate?.textViewDidBeginEditing?(textView)
        textView.isEditable = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewDelegate?.textViewDidEndEditing?(textView)
        textView.isEditable = false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = textView.text.isNotEmpty
        textViewDelegate?.textViewDidChange?(textView)
    }
}
