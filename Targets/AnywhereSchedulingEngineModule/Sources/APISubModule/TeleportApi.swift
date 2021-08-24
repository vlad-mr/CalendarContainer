//
//  TeleportApi.swift
//  AnywhereSchedulingEngineModule
//
//  Created by Artem Grebinik on 16.08.2021.
//

import Foundation
import Moya
import PromiseKit

struct TeleportApiConfiguration {
    var baseURL = URL(string: "https://staging.teleport.video/v1")!
    var accessToken: String? = ""
    let isLiveEnvironment: Bool = false
    static var current = TeleportApiConfiguration()
}

// MARK: - Welcome

public struct Meeting: Codable {
    var accountId: String?
    var brandId: String?
    var businessName: String?
    var ownerContactId: String?
    var startsAt: Int?
    var roomType: String?
    var hipaaCompliant: Bool?
    var appointmentId: String?
    var hostIds: [String]?
    var features: Features?

    enum CodingKeys: String, CodingKey {
        case accountId
        case brandId
        case businessName
        case ownerContactId
        case startsAt
        case roomType
        case hipaaCompliant
        case appointmentId
        case hostIds
        case features
    }
}

public struct MeetingApiResponse<Response: Codable>: Codable {
    public let status: String?
    public let message: String?
    public let data: Response?
}

// MARK: - DataClass

public struct MeetingDataDTO: Codable {
    var meetingUrl: String?
    var meetingId: String?

    enum CodingKeys: String, CodingKey {
        case meetingUrl
        case meetingId
    }
}

// MARK: - Features

public struct Features: Codable {
    var waitForHost, lockRoom, customization: Bool?
}

enum TeleportApi {
    case createMeeting(_ param: [String: Any])
}

extension TeleportApi: TargetType {
    var baseURL: URL { TeleportApiConfiguration.current.baseURL }

    var path: String {
        switch self {
        case .createMeeting:
            return "/meeting"
        }
    }

    var method: Moya.Method {
        switch self {
        case .createMeeting:
            return .post
        }
    }

    var sampleData: Data {
        switch self {
        case let .createMeeting(param):
            let jsonData = MeetingApiResponse<MeetingDataDTO>(status: "success",
                                                              message: "success message",
                                                              data: MeetingDataDTO(meetingUrl: UUID().uuidString,
                                                                                   meetingId: UUID().uuidString))

            return jsonData.toJsonData!
        }
    }

    var parameters: [String: Any] {
        return [:]
    }

    var task: Task {
        switch self {
        case let .createMeeting(param):
            return .requestParameters(parameters: param, encoding: JSONEncoding.default)
        }
    }

    var headers: [String: String]? {
        switch self {
        default:
            guard let accessToken = TeleportApiConfiguration.current.accessToken else { return nil }
            return ["Authorization": "Bearer \(accessToken)"]
        }
    }
}

public protocol TeleportApiProtocol {
    func createMeeting(withParameters params: [String: Any]) -> Promise<Data>
}

class TeleportApiService: BaseApiProvider, TeleportApiProtocol {
    private(set) var provider: MoyaProvider<TeleportApi>

    init(provider: MoyaProvider<TeleportApi> = MoyaProvider<TeleportApi>()) {
        self.provider = provider
    }

    func createMeeting(withParameters params: [String: Any]) -> Promise<Data> {
        return Promise<Data> { promise in
            provider.request(.createMeeting(params)) {
                let response = self.handleResponse($0)
                guard let data = self.handleResponse($0).data else {
                    promise.reject(response.error ?? APIError.unknown)
                    return
                }
                promise.fulfill(data)
            }
        }
    }
}

public protocol MeetingServiceProtocol {
    func createMeeting(withParameters params: [String: Any]) -> Promise<MeetingDataDTO>
}

final class MeetingService: MeetingServiceProtocol {
    let api: TeleportApiProtocol

    init(api: TeleportApiProtocol) { self.api = api }

    func createMeeting(withParameters params: [String: Any]) -> Promise<MeetingDataDTO> {
        return Promise<MeetingDataDTO> { promise in
            firstly {
                self.api.createMeeting(withParameters: params)
            }.compactMap {
                MeetingApiResponse<MeetingDataDTO>.decode(fromJsonData: $0)
            }.then {
                self.validateResponse($0)
            }.done { meeting in
                Logger.info("Create event successful and saved in core data pod=)")
                promise.fulfill(meeting)
            }.catch {
                promise.reject($0)
            }
        }
    }

    private func validateResponse(_ response: MeetingApiResponse<MeetingDataDTO>) -> Promise<MeetingDataDTO> {
        return Promise<MeetingDataDTO> { promise in
            guard let meetingData = response.data else {
                if let status = response.status, status != "success" {
                    promise.reject(AppError.apiFailed)
                }
                return
            }
            promise.fulfill(meetingData)
        }
    }
}
