//
//  EventDateCell.swift
//  Anytime
//
//  Created by Vignesh on 11/01/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

class EventCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var iconImageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageWidthConstaint: NSLayoutConstraint!
    
    func changeLeadingContraint(to constant: CGFloat) {
        iconImageLeadingConstraint.constant = constant
    }
    
    func updateImageSize(to value: CGFloat) {
        imageWidthConstaint.constant = value
        imageHeightConstraint.constant = value
        iconImageView.layer.cornerRadius = value / 2
    }
    
    func updateView() {
        if iconImageView.image == nil {
            iconImageLeadingConstraint.constant = 0
            updateImageSize(to: 0)
        } else {
            iconImageLeadingConstraint.constant = 20
            updateImageSize(to: 32)
        }
    }
    
    func setImage(_ image: UIImage?) {
        iconImageView.image = image
    }
    
}

class EventDateCell: EventCell, NibLoadable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var icon: UIImage?
    var title: String?
    var dateString: String?
    var timeString: String?
    
    var isDisabled: Bool = false {
        didSet {
            disableCell(isDisabled)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.font = AppDecor.Fonts.medium.withSize(13)
        dateLabel.font = AppDecor.Fonts.medium.withSize(15)
        timeLabel.font = AppDecor.Fonts.medium.withSize(15)
        dateLabel.textColor = UIColor.black
    }
    
    // Can be used for static cell generation based on the type
    //    enum CellType {
    //        case start, end
    //    }
    
    func configureCell(withTitle title: String?, icon: UIImage?, shouldShowSeparator: Bool = false) {
        if let cellTitle = title {
            titleLabel.text = cellTitle
        } else {
            titleLabel.removeFromSuperview()
        }
        iconImageView.image = icon
        separatorView.isHidden = !shouldShowSeparator
    }
    
    func set(date: String, time: String) {
        dateLabel.text = date
        timeLabel.text = time
    }
    
    private func disableCell(_ isEnabled: Bool) {
        
        titleLabel.isEnabled = isEnabled
        dateLabel.isEnabled = isEnabled
        timeLabel.isEnabled = isEnabled
    }
}
