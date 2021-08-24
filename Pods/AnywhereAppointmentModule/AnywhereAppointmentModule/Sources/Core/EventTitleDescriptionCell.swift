//
//  EventTitleDescriptionCell.swift
//  Anytime
//
//  Created by Vignesh on 13/01/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

class EventTitleDescriptionCell: EventCell, NibLoadable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var stackHeight: NSLayoutConstraint!
    
    private var enabledStateTitle: String = ""
    private var emptyStateTitle: String = ""
    
    var mode = CellMode.enabled {
        didSet {
            customizeCell(forMode: mode)
        }
    }
    enum CellMode {
        case enabled, disabled, empty
//        case withOutDescription
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        customizeCell(forMode: mode)
        self.separatorInset.right = .greatestFiniteMagnitude
    }
    
    private func customizeCell(forMode mode: CellMode) {
        DispatchQueue.main.async {
            self.descriptionLabel.isHidden = false
            switch mode {
            case .enabled:
                self.titleLabel.font = AppDecor.Fonts.medium.withSize(13)
                self.titleLabel.textColor = UIColor.black.withAlphaComponent(0.5)
                self.titleLabel.text = self.enabledStateTitle
                self.descriptionLabel.font = AppDecor.Fonts.medium.withSize(15)
                self.descriptionLabel.textColor = .black
            case .disabled:
                self.titleLabel.font = AppDecor.Fonts.medium.withSize(15)
                self.titleLabel.textColor = UIColor(red: 150, green: 150, blue: 150)
                self.descriptionLabel.font = AppDecor.Fonts.medium.withSize(13)
                self.descriptionLabel.textColor = UIColor.black.withAlphaComponent(0.3)
                self.descriptionLabel.text = self.emptyStateTitle
            case .empty:
                self.titleLabel.font = AppDecor.Fonts.medium.withSize(15)
                self.titleLabel.text = self.emptyStateTitle
                self.titleLabel.textColor = .black
                self.descriptionLabel.isHidden = true
            }
        }
    }
    
    func configureCell(withTitle enabledTitle: String, titleForEmptyState emptyTitle: String = "", icon: UIImage?, mode: CellMode = .enabled, shouldShowSeparator: Bool = false) {
        self.mode = mode
        enabledStateTitle = enabledTitle
        emptyStateTitle = emptyTitle
        titleLabel.text = self.mode == .enabled ? enabledTitle : emptyTitle
        setImage(icon)
        separatorView.isHidden = !shouldShowSeparator
        customizeCell(forMode: mode)
    }
    
    func setDescription(_ description: String) {
        mode = description.isEmpty ? .empty : .enabled
        customizeCell(forMode: mode)
        titleLabel.text = mode == .enabled ? enabledStateTitle : emptyStateTitle
        descriptionLabel.text = description
    }
    
    func removeDescription() {
        customizeCell(forMode: .disabled)
        descriptionLabel.text = ""
    }
    
    func updateContentStackHeight(height: CGFloat) {
        stackHeight.constant = height
        self.layoutIfNeeded()
    }
}
