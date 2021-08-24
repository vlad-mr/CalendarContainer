//
//  IconIndicatorTableViewCell.swift
//  Anytime
//
//  Created by Artem Grebinik on 25.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

class IconIndicatorTableViewCell: IndicatorTableViewCell, NibLoadable {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.font = AppDecor.Fonts.medium.withSize(15)
    }

    func configure(withLabelTitle title: String, icon: UIImage?, color: UIColor? = .black, indicatorImage: UIImage? = nil, shouldShowSeparator: Bool = false) {
        titleLabel.text = title
        titleLabel.textColor = color
        iconImageView.image = icon
        separatorView.isHidden = !shouldShowSeparator
        setIndicatorImage(indicatorImage)
    }
}
