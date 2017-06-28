//
//  Time.swift
//  scheduler-ios
//
//  Created by Rizadh Nizam on 2017-06-12.
//  Copyright © 2017 Rizadh Nizam. All rights reserved.
//

import Foundation

struct Time {
    let hour: Int
    let minute: Int

    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }

    init(fromMinutes: Int) {
        guard fromMinutes > 0 else {
            fatalError("Cannot create a Time instance with negative minutes.")
        }

        guard fromMinutes < 24 * 60 else {
            fatalError("Cannot create a Time instance with more than 24 hours.")
        }
        
        var minutes = fromMinutes
        
        var hours = 0

        while minutes >= 60 {
            hours += 1
            minutes -= 60
        }
        
        self.hour = hours
        self.minute = minutes
    }
    
    var minutes: Int {
        return 60 * self.hour + self.minute
    }
}

extension Time: Equatable {
    static func == (lhs: Time, rhs: Time) -> Bool {
        return lhs.minutes == rhs.minutes
    }
}

extension Time: Comparable {
    static func < (lhs: Time, rhs: Time) -> Bool {
        return lhs.minutes < rhs.minutes
    }
}

extension Time: CustomStringConvertible {
    var description: String {
        var descriptionString = ""

        if hour < 10 {
            descriptionString += "0"
        }
        
        descriptionString += String(hour)
        
        descriptionString += ":"
        
        if minute < 10 {
            descriptionString += "0"
        }
        
        descriptionString += String(minute)
     
        return descriptionString
    }
}
