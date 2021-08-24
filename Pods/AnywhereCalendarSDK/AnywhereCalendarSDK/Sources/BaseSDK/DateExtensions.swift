//
//  DateExtensions.swift
//  AnywhereCalendarSDK
//
//  Created by Vignesh on 08/09/20.
//

import Foundation

extension DateFormatter {
    static let zulu: DateFormatter = {
        let en_US_POSIX = Locale(identifier: "en_US_POSIX")
        let rfc3339DateFormatter = DateFormatter()
        rfc3339DateFormatter.locale = en_US_POSIX
        rfc3339DateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssX"
        rfc3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return rfc3339DateFormatter
    }()
    
    static let standard: DateFormatter = {
        let en_US_POSIX = Locale(identifier: "en_US_POSIX")
        let stdDateFormatter = DateFormatter()
        stdDateFormatter.locale = en_US_POSIX
        stdDateFormatter.dateFormat = "dd'/'MM'/'yyyy"
        stdDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return stdDateFormatter
    }()
}

extension Date {
    init?(fromZuluString zuluString: String) {
        guard let date = DateFormatter.zulu.date(from: zuluString) else {
            return nil
        }
        self = date
    }
    
    public init?(fromString dateString: String) {
        guard let date = DateFormatter.standard.date(from: dateString) else {
            return nil
        }
        self = date
    }
    
    public var standardDateString: String {
        DateFormatter.standard.string(from: self)
    }
}

