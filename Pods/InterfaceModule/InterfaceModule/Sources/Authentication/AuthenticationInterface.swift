//
//  AuthenticationInterface.swift
//  InterfaceModule
//
//  Created by Vignesh on 22/07/21.
//

import Foundation
import UIKit

/// An Interface that executes actions related to Authentication on Request
public protocol AuthenticationActionInterface {
    
    func showErrorAlert(with message: String)
}

/// An Interface that handles Callbacks from Authentication for Requested Actions
public protocol AuthenticationCallbackInterface {
    
    func didCompleteAuthentication(with data: AuthenticatedData)
}
