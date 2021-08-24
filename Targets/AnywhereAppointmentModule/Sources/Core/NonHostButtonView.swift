//
//  NonHostButtonView.swift
//  EventViewSDK
//
//  Created by Artem Grebinik on 10.08.2021.
//

import UIKit

protocol NonHostButtonViewDelegate: class {
    func didTapAcceptButton()
    func didTapDeclineButton()
}

class NonHostButtonView: UIView, NibLoadable {
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var acceptButton: StatefulButton!
    @IBOutlet var declineButton: StatefulButton!
    weak var delegate: NonHostButtonViewDelegate?

    var responseStatus: ResponseStatus = .pending {
        didSet {
            switch responseStatus {
            case .accepted, .tentative:
                acceptButton.mode = .selected
                declineButton.mode = .unselected
            case .pending:
                acceptButton.mode = .unselected
                declineButton.mode = .unselected
            case .declined:
                acceptButton.mode = .unselected
                declineButton.mode = .selected
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    func setupView() {
        acceptButton.configure(selectedModeTitle: "Accepted", unselectedModeTitle: "Accept", color: AppDecor.CardColors.fern, icon: AppDecor.Icons.tickCircle)
        declineButton.configure(selectedModeTitle: "Declined", unselectedModeTitle: "Decline", color: AppDecor.CardColors.mandy, icon: AppDecor.Icons.crossCircle)
    }

    @IBAction func didTapAcceptButton(_: Any) {
        delegate?.didTapAcceptButton()
    }

    @IBAction func didTapDecline(_: Any) {
        delegate?.didTapDeclineButton()
    }
}
