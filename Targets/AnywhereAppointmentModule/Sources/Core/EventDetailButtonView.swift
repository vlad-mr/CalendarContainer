//
//  HostButtonView.swift
//  Anytime
//
//  Created by Deepika on 17/04/20.
//  Copyright © 2020 FullCreative Pvt Ltd. All rights reserved.
//

import UIKit

protocol EventDetailActionsDelegate: class {
    func didTapAcceptButton()
    func didTapDeclineButton()
    func didTapSaveButton()
}

class EventDetailButtonView: UIView {
    var mode: EventViewMode = .host {
        didSet {
            setupView()
        }
    }

    weak var delegate: EventDetailActionsDelegate?

    lazy var hostButtonView: HostButtonView = configure(AnytimeNibs.hostButtonView) {
        $0.delegate = self
        $0.frame = self.bounds
    }

    lazy var nonHostView: NonHostButtonView = configure(AnytimeNibs.nonHostButtonView) {
        $0.delegate = self
        $0.frame = self.bounds
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func didUpdate(shouldSave: Bool) {
        hostButtonView.saveButton.isEnabled = shouldSave
    }

    func setupView() {
        switch mode {
        case .host:
            addSubview(hostButtonView)
        case .nonHost:
            addSubview(nonHostView)
        }
    }

    func setResponseStatus(_ responseStatus: ResponseStatus) {
        nonHostView.responseStatus = responseStatus
    }
}

extension EventDetailButtonView: NonHostButtonViewDelegate {
    func didTapAcceptButton() {
        delegate?.didTapAcceptButton()
    }

    func didTapDeclineButton() {
        delegate?.didTapDeclineButton()
    }
}

extension EventDetailButtonView: HostButtonViewDelegate {
    func didTapSaveButton() {
        delegate?.didTapSaveButton()
    }
}
