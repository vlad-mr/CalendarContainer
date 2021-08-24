//
//  ApiHelper.swift
//  AnytimeAPI
//
//  Created by Monica on 24/12/19.
//  Copyright © 2019 FullCreative Pvt Ltd. All rights reserved.
//

import PromiseKit

struct ParameterEncodingHelper {
    
    enum EncodingError: Error {
        case invalidData(Any)
    }
    
    func convert(object: Any, encoding: String.Encoding = .utf8) throws -> String {
        var jsonData: Data
        do {
            jsonData = try JSONSerialization.data(withJSONObject: object, options: [])
        } catch let error {
            throw error
        }
        
        guard let encodedString = String(data: jsonData, encoding: encoding) else { throw EncodingError.invalidData(object) }
        return encodedString
    }
}

public final class ApiResponseValidator {
    public class func validateResponse<T>(_ response: SchedulingEngineApiResponse<T>) -> Promise<T> {
     
        return Promise<T> { promise in
            guard response.status, let requiredData = response.data else {
                if let error = response.error, let apiError = APIError(rawValue: error) {
                    promise.reject(apiError)
                } else {
                    promise.reject(APIError.apiFailed)
                }
                return
            }
            promise.fulfill(requiredData)
        }
    }
}
