//
//  SleepEntry.swift
//  lemmenap
//
//  Created by Sarvesh on 11/10/18.
//  Copyright © 2018 Sarvesh. All rights reserved.
//

import Foundation

struct SleepDetails{
    var sleepStart: Date
    var sleepEnd: Date
  //  var selectedDuration: Int
    var actualDuration: TimeInterval {
        return sleepEnd.timeIntervalSince(sleepStart)
    }
    let date: Date
    
}

class SleepHistory {
    static let sharedInstance = SleepHistory()
    var allSleeps: [SleepDetails] = []
}



