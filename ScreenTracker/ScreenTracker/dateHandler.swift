//
//  dateHandler.swift
//  ScreenTracker
//
//  Created by Donghan Hu on 2/20/23.
//

import Foundation

class dateHandlerClass {
    
    public func logFileWithDate() -> String{
        let date = NSDate()
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        let year = String(components.year! as Int)
        let month = String(components.month! as Int)
        let day = String(components.day! as Int)
        let fileName = month + "-" + day + "-" + year
        // print("logging file with date is :" + fileName)
        return fileName
    }
    
}
