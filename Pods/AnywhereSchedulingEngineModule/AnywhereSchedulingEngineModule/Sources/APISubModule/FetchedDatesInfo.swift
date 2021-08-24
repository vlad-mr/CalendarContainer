//
//  Fetch.swift
//  AnywhereSchedulingEngineModule
//
//  Created by Artem Grebinik on 28.07.2021.
//

import Foundation
import SwiftDate

class FetchedDatesInfo {
    
    static let shared = FetchedDatesInfo()
    let dateFormat = "ddMMyyyy"
    // Currently keeping the range from 30 days before to 60 days after.
    lazy var minDateInRange = Date().dateByAdding(-30, .day).date
    lazy var maxDateInRange = Date().dateByAdding(60, .day).date
    private let filepath = Utilities.getDocumentsDirectory().appendingPathComponent("FetchedDatesInfo")
    
    var fetchedDatesForId = Dictionary<String, Set<String>>()

    let internalQueue = DispatchQueue(label: "FetchedDatesInfoThread", qos: .userInitiated, attributes: .concurrent)
    
    func isAlreadyFetched(date: Date, for userId: String) -> Bool {
      return internalQueue.sync {
          guard isDateInRange(date) else {
              return false
          }
          return fetchedDatesForId[userId]?.contains(date.toString(.custom(dateFormat))) ?? false
      }
    }
    
    private func isDateInRange(_ date: Date) -> Bool {
        return date.isAfterDate(minDateInRange, granularity: .day) && date.isBeforeDate(maxDateInRange, granularity: .day)
    }

    func addFetchedDate(_ date: Date, for userId: String) {
      internalQueue.sync(flags: .barrier) {
        guard isDateInRange(date) else {
          return
        }
        if let currentDatesSet = self.fetchedDatesForId[userId] {
          var mutableDateSet = currentDatesSet
          mutableDateSet.insert(date.toString(.custom(self.dateFormat)))
          fetchedDatesForId[userId] = mutableDateSet
        } else {
          var newSet = Set<String>()
          newSet.insert(date.toString(.custom(self.dateFormat)))
          fetchedDatesForId[userId] = newSet
        }
      }
    }

    func areDatesAlreadyFetched(from startDate: Date, to endDate: Date, for userId: String) -> Bool {

      let dates = getAllDates(from: startDate, to: endDate)
      return dates.allSatisfy { isAlreadyFetched(date: $0, for: userId) }
    }

    func addFetchedDates(from startDate: Date, to endDate: Date, for userId: String) {
      var fromDate = startDate
      var toDate = endDate
      if !isDateInRange(startDate) && startDate.isBeforeDate(minDateInRange, granularity: .day) {
          fromDate = minDateInRange
      }

      if !isDateInRange(endDate), endDate.isAfterDate(maxDateInRange, granularity: .day) {
          toDate = maxDateInRange
      }

      let dates = getAllDates(from: fromDate, to: toDate)
      for date in dates {
          addFetchedDate(date, for: userId)
      }
    }
    
    private func getAllDates(from startDate: Date, to endDate: Date) -> [Date] {
        
        let firstDate = startDate.dateAt(.startOfDay)
        let lastDate = endDate.dateAt(.startOfDay)
        var dates = [firstDate]
        guard let diff = firstDate.difference(in: .day, from: lastDate), diff != 0 else {
            return dates
        }
        let absoluteDiff = abs(diff)
        switch absoluteDiff {
        case 1:
            dates.append(lastDate)
            return dates
        default:
            for i in 1...absoluteDiff {
                dates.append(firstDate.dateByAdding(i, .day).date)
            }
            return dates
        }
    }
    
    func clearFetchedDates() {
        internalQueue.sync(flags: .barrier) {
            self.fetchedDatesForId.removeAll()
        }
    }
    
    func loadFetchedDates() {
        internalQueue.sync(flags: .barrier) {
            do {
                let data = try Data(contentsOf: self.filepath)
              if let loadedDatesForId = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Dictionary<String, Set<String>> {
                self.fetchedDatesForId = loadedDatesForId
              } else {
                self.fetchedDatesForId = [:]
              }
            } catch {
                print("Couldn't write to fetched dates file")
            }
        }
    }
    
    func saveFetchedDates() {
        internalQueue.sync(flags: .barrier) {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: self.fetchedDatesForId, requiringSecureCoding: false)
                try data.write(to: filepath)
            } catch {
                print("Couldn't write to fetched dates file")
            }
        }
    }
}
