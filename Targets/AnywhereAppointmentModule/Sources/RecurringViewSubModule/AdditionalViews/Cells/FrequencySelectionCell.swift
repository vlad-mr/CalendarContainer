//
//  FrequencySelectionCell.swift
//  Anytime
//
//  Created by Artem Grebinik on 25.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

class FrequencySelectionCell: SeparatorTableViewCell, NibLoadable {
    @IBOutlet var selectionView: UIImageView!
    @IBOutlet var titleLabel: UILabel!

    var isDurationSelected: Bool = false {
        didSet {
            selectionView.image = isDurationSelected ? AppDecor.Icons.selectedCell : AppDecor.Icons.unselectedCell
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        titleLabel.font = AppDecor.Fonts.medium.withSize(15)
        titleLabel.text = ""
        titleLabel.textColor = .black
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func configureCell(withTitle title: String, isSelected: Bool = false, shouldShowSeparator: Bool = false) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.22

        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.attributedText = NSMutableAttributedString(
            string: title,
            attributes: [
                NSAttributedString.Key.font: AppDecor.Fonts.medium.withSize(15),
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
            ]
        )

        separatorView.isHidden = !shouldShowSeparator
        isDurationSelected = isSelected
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}
