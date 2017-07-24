//
//  Date+Milliseconds.swift
//  TinkoffNews
//
//  Created by user on 24.07.17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:UIntMax) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}
