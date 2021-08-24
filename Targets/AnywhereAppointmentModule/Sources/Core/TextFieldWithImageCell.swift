//
//  TextFieldWithImageCell.swift
//  Anytime
//
//  Created by Deepika on 29/04/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

class TextFieldWithImageCell: EventTextFieldCell, NibLoadable {
    @IBOutlet var sourceIconWidthContraint: NSLayoutConstraint!
    @IBOutlet var sourceIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(withPlaceHolder placeholderText: String, icon: UIImage?, shouldShowSeparator: Bool = false, imageSize: CGFloat = 32, sourceIcon: UIImage?) {
        super.configureCell(withPlaceHolder: placeholderText, icon: icon, shouldShowSeparator: shouldShowSeparator, imageSize: imageSize)
        setSourceIcon(sourceIcon)
    }

    func setSourceIcon(_ image: UIImage?) {
        guard let image = image else {
            sourceIconWidthContraint.constant = 0
            return
        }
        sourceIconWidthContraint.constant = 16
        sourceIcon.image = image
    }
}
