//
//  CommonUtils.swift
//  For all swift projects
//
//  Created by super on 01/08/2016.
//  Copyright © 2016 super. All rights reserved.
//

import UIKit

class CommonUtils: NSObject {
    
    // show alert view
    static func showAlert(title: String, message: String) {

        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController
        rootVC?.presentViewController(ac, animated: true){}
    }
    
    static func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if cString.hasPrefix("#") {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if cString.characters.count != 6 {
            return UIColor.grayColor()
        }
        
        var rgbValue : UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

// for get date
extension NSDate {
    // year
    var year: String {
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Year, .Month, .Day], fromDate: self)
        
        return ("\(comp.year)")
    }
    
    // week day
    var weekDay: String {
        var weeks = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Year, .Month, .Day, .Weekday], fromDate: self)
        
        return weeks[comp.weekday-1]
    }
    
    // month
    var month: String {
        var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Year, .Month, .Day, .Weekday], fromDate: self)
        
        return months[comp.month-1]
    }
    
    // month - Number
    var monthNum: String {
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Year, .Month, .Day, .Weekday], fromDate: self)
        
        return ("\(comp.month)")
    }
    
    // week day
    var date: String {
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Year, .Month, .Day, .Weekday], fromDate: self)
        
        return ("\(comp.day)")
    }
    
    // hour
    var hour: String {
        get {
            let calendar = NSCalendar.currentCalendar()
            let comp = calendar.components([.Hour, .Minute], fromDate: self)
            
            var hour = comp.hour
            
            if self.AMPM == "PM" {
                hour = hour - 12
            }
            
            return "\(hour)"
        }
    }
    
    var hourAMPM: String {
        get {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH"
            
            return dateFormatter.stringFromDate(self)
        }
    }
    
    var minute: String {
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "mm"
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Hour, .Minute], fromDate: self)
        
        return ("\(comp.minute)")
    }
    
    var second: String {
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "ss"
//        return dateFormatter.stringFromDate(self)
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Hour, .Minute, .Second], fromDate: self)
        
        return ("\(comp.second)")
    }
    
    // AM & PM
    var AMPM: String {
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components([.Hour], fromDate: self)
        if comp.hour > 12 {
            return "PM"
        }
        
        return "AM"
    }
    
    // Compare date and returns this type. "03:19:23"
    func compareWithPrayerDate(toDate: NSDate) -> String{
        var hourDifference = Int(toDate.hour)! - Int(self.hour)!
        if hourDifference < 0{
            hourDifference = hourDifference + 12
        }
        var minuteDifference = Int(toDate.minute)! - Int(self.minute)!
        // If minute differnece is minus
        if minuteDifference < 0{
            hourDifference = hourDifference - 1
            minuteDifference = minuteDifference + 60
        }
        var secondDifference = Int(toDate.second)! - Int(self.second)!
        // If minute differnece is minus
        if secondDifference < 0{
            minuteDifference = minuteDifference - 1
            if minuteDifference < 0{
                hourDifference = hourDifference - 1
                minuteDifference = minuteDifference + 60
            }
            secondDifference = secondDifference + 60
        }
        
        let returnString = String(format: "%02d:%02d:%02d", hourDifference, minuteDifference, secondDifference)
        return returnString
    }
    
    func durationUntilNextPrayer(dateToCompare: NSDate) -> String{
        var hour = Int(dateToCompare.hour)! - Int(self.hour)!
        if hour < 0{
            hour = hour + 12
        }
        var min = Int(dateToCompare.minute)! - Int(self.minute)!
        if min < 0{
            min = min + 60
            hour = hour - 1
        }
        return "\(hour)h \(min) m"
    }
    
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
}
