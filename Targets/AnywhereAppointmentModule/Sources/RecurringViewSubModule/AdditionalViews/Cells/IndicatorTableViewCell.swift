//
//  IndicatorTableViewCell.swift
//  Anytime
//
//  Created by Artem Grebinik on 25.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

class IndicatorTableViewCell: SeparatorTableViewCell {
    @IBOutlet var indicatorView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(indicatorImage: UIImage? = nil, shouldShowSeparator: Bool = false) {
        separatorView.isHidden = !shouldShowSeparator
        setIndicatorImage(indicatorImage)
    }

    func setIndicatorImage(_ image: UIImage?) {
        guard let image = image else {
            hideIndicator()
            return
        }
        indicatorView.image = image

        indicatorView.tintColor = UIColor.lightGray.withAlphaComponent(0.5)
    }

    private func hideIndicator() {
        indicatorView.isHidden = true
    }
}
