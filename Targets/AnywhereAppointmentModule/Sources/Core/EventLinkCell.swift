//
//  EventLinkCell.swift
//  Anytime
//
//  Created by Vignesh on 13/01/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

protocol EventLinkCellDelegateProtocol: class {
    func share(link: String)
    func didCopyLink()
    func actionForLink(_ link: String)
}

class EventLinkCell: EventCell, NibLoadable {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var linkLabel: UILabel!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var copyButton: UIButton!

    weak var delegate: EventLinkCellDelegateProtocol?

    enum CellMode {
        case noShare, shouldShare
    }

    var shouldShowDescription: Bool = true {
        didSet {
            descriptionLabel.isHidden = !shouldShowDescription
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        titleLabel.font = AppDecor.Fonts.medium.withSize(13)
        titleLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        descriptionLabel.font = AppDecor.Fonts.medium.withSize(15)
        descriptionLabel.textColor = .black
        linkLabel.font = AppDecor.Fonts.medium.withSize(15)
        linkLabel.textColor = AppDecor.MainColors.anytimeLightBlue
        linkLabel.isUserInteractionEnabled = true
        copyButton.addTarget(self, action: #selector(didTapCopy), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLink))
        linkLabel.isUserInteractionEnabled = true
        linkLabel.addGestureRecognizer(tapGesture)
    }

    func configureCell(forMode mode: CellMode, withTitle title: String, description: String, icon: UIImage?, shouldShowDescription: Bool = true, shouldShowSeparator: Bool = false) {
        titleLabel.text = title
        descriptionLabel.text = description
        linkLabel.text = ""
        iconImageView.image = icon
        separatorView.isHidden = !shouldShowSeparator
        toggleCellMode(to: mode)
        self.shouldShowDescription = shouldShowDescription
    }

    func setLink(_ link: String) {
        linkLabel.text = link
    }

    func toggleCellMode(to mode: CellMode) {
        switch mode {
        case .noShare:
            shareButton.isHidden = true
            copyButton.isHidden = true
        case .shouldShare:
            shareButton.isHidden = false
            copyButton.isHidden = false
        }
    }

    @objc private func didTapLink() {
        guard let link = linkLabel.text else { return }
        delegate?.actionForLink(link)
    }

    @objc private func didTapCopy() {
        UIPasteboard.general.string = linkLabel.text
        delegate?.didCopyLink()
    }

    @objc private func didTapShare() {
        guard let link = linkLabel.text else { return }
        delegate?.share(link: link)
    }
}
