//
//  TitleSubtitleIndicatorCell.swift
//  Anytime
//
//  Created by Artem Grebinik on 25.06.2021.
//  Copyright © 2021 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

class TitleSubtitleIndicatorCell: IndicatorTableViewCell, NibLoadable {
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!

    private var enabledStateTitle: String = ""
    private var emptyStateTitle: String = ""

    var mode = CellMode.enabled {
        didSet {
            customizeCell(forMode: mode)
        }
    }

    enum CellMode {
        case enabled, disabled, empty
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        customizeCell(forMode: mode)
        separatorInset.right = .greatestFiniteMagnitude
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
                self.titleLabel.textColor = UIColor(red: 150, green: 150, blue: 150, alpha: 1)
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

    func configureCell(withTitle enabledTitle: String,
                       titleForEmptyState emptyTitle: String = "",
                       icon: UIImage?, indicatorIcon: UIImage? = nil,
                       mode: CellMode = .enabled,
                       shouldShowSeparator: Bool = false)
    {
        self.mode = mode
        enabledStateTitle = enabledTitle
        emptyStateTitle = emptyTitle
        titleLabel.text = self.mode == .enabled ? enabledTitle : emptyTitle
        setImage(icon)
        setIndicatorImage(indicatorIcon)
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

    func setImage(_ image: UIImage?) {
        iconImageView.image = image
    }
}
