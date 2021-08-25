//
//  AnywhereSessionInterface.swift
//  AnywhereInterfaceModule
//
//  Created by Vignesh on 23/07/21.
//

import Foundation

// We can give the role of contacting FullAuth to the Session Module as it is responsible to store/refresh/destroy the token. Also in Create Account Flow, we do
// MARK: Session Creation and Saving AppUser into local
public protocol SessionInterface {
    
    var accessToken: String? { get }
    var user: AppUser? { get }
//    var brandUserData: Data { get } // JSON or DICT would be better
    var hasValidSession: Bool { get }
    
    var callbackInterface: SessionCallbackInterface? { get set }
    
    func setupSession(for authData: AuthenticatedData)
    
    // Will be called on App Launch and any 401 issues
    /// Validate the current session and refresh if required
    func validateAndRefreshSession()
    
    // Will be called when Container wants to invalidate/end the session
    /// Invalidates or Ends the current active session
    func invalidateSession()
    
    func getRawUserData() -> Data?
    
    // Convert to Model
//    func updateUserData(_ user: Data)
    
    // on call of SETUP AND VALIDATE SESSION, THE SESSION MODULE will persists and keep the TOKEN object in Memory
    // onb call of INVALIDATE SESSION, THE SESSION MODULE will DESTORY TOKENS from MEMORY and KEYCHAIN
    // should we allow shared TOKENS like FACEBOOK does
    // APPKEYCHAIN
    // SHAREDKEYCHAIN -- CAN be explored
}


public protocol SessionCallbackInterface {
    
    func didCompleteSetup(withError error: Error?)
    func didRefreshSession()
    func didInvalidateSession(withError error: Error?)
}

/*

 ITEMS TO WORK ON
 
 -- Build Interface
 -- Prepare an idea for Persisting Token in Keychain
 -- Create a layer for Getting Token From AnywhereAuth
 -- Create a layer for Accessing AppBased Backends for SignIn (Think of adding Create Account with a simple Switch) { This should accept a brand from the Session module }
 -- Create Brand Based Account Service (Sign In methods)
 -- Prepare a layer to Persist User Information (both Common and BrandBasedUserData)
 
*/
