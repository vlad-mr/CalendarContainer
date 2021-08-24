//
//  SeparatorTableViewCell.swift
//  Anytime
//
//  Created by Artem Grebinik on 25.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

class SeparatorTableViewCell: UITableViewCell {
    @IBOutlet var separatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        separatorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
    }

    func congigure(shouldShowSeparator: Bool = false) {
        separatorView.isHidden = !shouldShowSeparator
    }
}
