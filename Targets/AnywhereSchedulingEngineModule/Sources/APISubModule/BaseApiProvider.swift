//
//  BaseApiProvider.swift
//  AnytimeAPI
//
//  Created by Monica on 02/12/19.
//  Copyright © 2019 FullCreative Pvt Ltd. All rights reserved.
//

import Foundation
import Moya

protocol BaseApiProvider {}

extension BaseApiProvider {
    typealias MoyaResponse = (data: Data?, error: Error?)

    static func defaultPlugins() -> [PluginType] {
        guard Configuration.current.isLiveEnvironment else {
            return []
        }

        return [NetworkLoggerPlugin()]
    }

    func handleResponse(_ result: Result<Response, MoyaError>) -> MoyaResponse {
        switch result {
        case let .success(response):
            do {
                _ = try response.filterSuccessfulStatusCodes()
                return (response.data, nil)

            } catch let err {
                return (nil, err)
            }

        case let .failure(error):
            let apiError = APIError(rawValue: error.errorDescription!)
            return (nil, apiError)
        }
    }
}
