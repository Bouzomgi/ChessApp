//
//  Date+hash.swift
//  Chess
//
//  Created by Brian Ouzomgi on 11/20/20.
//

import Foundation

extension Date {
    var hash : Int {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: self)
        
        return Int(dateString)!
    }
}
