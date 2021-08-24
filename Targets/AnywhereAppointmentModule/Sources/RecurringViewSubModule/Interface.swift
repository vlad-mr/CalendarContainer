//
//  Interface.swift
//  AnywhereAppointmentModule
//
//  Created by Vignesh on 06/07/21.
//

import Foundation

public enum AnywhereRecurringView {
    public static func getRecurringView(forInitialFrequency frequency: Frequency,
                                        eventStartDate: Date,
                                        delegate: FrequencyVCDelegate?) -> FrequencyViewController
    {
        let recurringView = FrequencyRouter.initialViewController
        recurringView.originalFrequencyMode = frequency
        recurringView.startEventDate = eventStartDate
        recurringView.delegate = delegate
        return recurringView
    }
}
