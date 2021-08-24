//
//  FrequencySelectionCell.swift
//  Anytime
//
//  Created by Artem Grebinik on 25.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

class FrequencySelectionCell: SeparatorTableViewCell, NibLoadable {
    @IBOutlet weak var selectionView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    var isDurationSelected: Bool = false {
        didSet {
            selectionView.image = isDurationSelected ? AppDecor.Icons.selectedCell : AppDecor.Icons.unselectedCell
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        self.titleLabel.font = AppDecor.Fonts.medium.withSize(15)
        self.titleLabel.text = ""
        self.titleLabel.textColor = .black
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell(withTitle title: String, isSelected: Bool = false, shouldShowSeparator: Bool = false) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.22
        
        self.titleLabel.lineBreakMode = .byWordWrapping
        self.titleLabel.attributedText = NSMutableAttributedString(
            string: title,
            attributes: [
                NSAttributedString.Key.font: AppDecor.Fonts.medium.withSize(15),
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ])

        separatorView.isHidden = !shouldShowSeparator
        self.isDurationSelected = isSelected
    }
    
    func setTitle(_ title: String) {
        self.titleLabel.text = title
    }
}
