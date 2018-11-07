//
//  SleepEntryDetail+CoreDataProperties.swift
//  
//
//  Created by Sarvesh on 06/11/18.
//
//

import Foundation
import CoreData


extension SleepEntryDetail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SleepEntryDetail> {
        return NSFetchRequest<SleepEntryDetail>(entityName: "SleepEntryDetail")
    }

    @NSManaged public var sleepEnd: NSDate
    @NSManaged public var sleepStart: NSDate
    //@NSManaged public var sectionIdentifier: String?
    
    @objc public var sectionIdentifier: String {
        willAccessValue(forKey: "sectionIdentifier")
        var tmp = primitiveSectionIdentifier
        didAccessValue(forKey: "sectionIdentifier")
        if tmp == "" {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month], from: sleepStart as Date)
            tmp = String(format: "%ld", (components.year! * 1000) + components.month!)
            self.primitiveSectionIdentifier = tmp
        }
        return tmp!
    }
    
//     // If the time stamp changes, the section identifier become invalid.
//    var sleepStartTemp: Date? {
//        get {
//            return sleepStart as Date?
//        }
//        set(newDate){
//            willChangeValue(forKey: "sleepStart")
//            self.primitiveTimeStamp = newDate
//            didChangeValue(forKey: "sleepStart")
//            self.primitiveSectionIdentifier = nil
//        }
//
//    }
    
    
//    #pragma mark - Key path dependencies
//      // in Objective C
//    + (NSSet *)keyPathsForValuesAffectingSectionIdentifier
//    {
//    // If the value of timeStamp changes, the section identifier may change as well.
//    return [NSSet setWithObject:@"timeStamp"];
//    }
}
