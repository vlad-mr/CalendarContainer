//
//  CustomRepeatRecurrencyCell.swift
//  Anytime
//
//  Created by Artem Grebinik on 17.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

// MARK: - CustomRepeatRecurrencyCell

class CustomRepeatRecurrencyCell: UITableViewCell, NibLoadable {
    @IBOutlet var textLable: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var separator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        textLable.font = AppDecor.Fonts.medium.withSize(13)
        textLable.textColor = UIColor.black.withAlphaComponent(0.5)
        separator.backgroundColor = UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1)
    }

    func configure(with title: String, shouldShowSeparator: Bool = false) {
        textLable?.text = title
        separator.isHidden = !shouldShowSeparator
    }
}
