//
//  ContactApiManager.swift
//  AnywhereContactModule
//
//  Created by Karthik on 17/06/21.
//

import Foundation
import AnywhereInterfaceModule

class ApiService {
	
}

class Validator {
	
}

public class ContactApi {
	
	public static let manger = {
		return ContactApi(
			apiService: ApiService(),
			validator: Validator(),
			dbService: ContactDB.manager
		)
	}()
	
	let apiService: ApiService
	let validator: Validator
	let dbService: DataBaseInterface
	
	// Xcttest
	init(apiService: ApiService, validator: Validator, dbService: ContactDB) {
		self.apiService = apiService
		self.validator = validator
		self.dbService = dbService
	}
	
	public func fetchapi() {
		
	}
}
