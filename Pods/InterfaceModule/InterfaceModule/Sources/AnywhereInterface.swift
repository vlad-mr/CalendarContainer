//
//  AnywhereInterface.swift
//  InterfaceModule
//
//  Created by Karthik on 18/06/21.
//

import UIKit

public enum AppBrand: String {
    case anytime = "Anytime"
    
    var bundleID: String {
        switch self {
        case .anytime:
            return "io.full.anytime"
        }
    }
}

// MARK: AppDelegate Interaface
public protocol AppDelegateInterface {
	func application(
		_ application: UIApplication,
		willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	)
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	)
	func appWillEnterForeground(_ application: UIApplication)
	func appDidEnterBackground(_ application: UIApplication)
	func appDidBecomeActive(_ application: UIApplication)
	func appWillResignActive(_ application: UIApplication)
	func appWillTerminate(_ application: UIApplication)
	func appSignificantTimeChange(_ application: UIApplication)
	func appDidReceiveMemoryWarning(_ application: UIApplication)
}

// MARK: Firebase Interface
public protocol FirebaseInterface {
	func didFetchRemoteConfig()
}

// MARK: Authentication (Login, Signup, ResetPassword)
public protocol AuthInterface {
	//
}

// MARK: Device Management (Register, UnRegister device)
public protocol DeviceManagmentInterface {
	//
}

// MARK: Service Brokers
public typealias ServiceBrokerInterfaceImplimenteds = DataBaseInterface
	& ApiInterface
	& UIInterface

public protocol ServiceBrokerInterface: ServiceBrokerInterfaceImplimenteds {

}

extension ServiceBrokerInterface {
	//
}
