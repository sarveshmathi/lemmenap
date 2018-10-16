import UIKit
import Foundation

struct SleepEntry{
    var sleepStart: Date
    var sleepEnd: Date
    var sleepDuration: Int {
        return sleepEnd.hashValue - sleepStart.hashValue
    }
    let date: Date
    
}

var entryOne = SleepEntry(sleepStart: Date(), sleepEnd: Date().addingTimeInterval(900), date: Date())

let dateFormatter = DateFormatter()
dateFormatter.dateStyle = .medium
dateFormatter.timeStyle = .medium



print(dateFormatter.string(from: entryOne.sleepStart))
print(dateFormatter.string(from: entryOne.sleepEnd))
