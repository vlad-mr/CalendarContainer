//
//  HostButtonView.swift
//  EventViewSDK
//
//  Created by Artem Grebinik on 10.08.2021.
//

import UIKit

protocol HostButtonViewDelegate: class {
    func didTapSaveButton()
}

class HostButtonView: UIView, NibLoadable {

    @IBOutlet weak var saveButton: RoundedButton!
    weak var delegate: HostButtonViewDelegate?
    
    @IBAction func didTapSaveButton(_ sender: RoundedButton) {
        delegate?.didTapSaveButton()
    }
    
}
