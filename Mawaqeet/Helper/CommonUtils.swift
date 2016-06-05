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
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYY"
        return dateFormatter.stringFromDate(self)
    }
    
    // week day
    var weekDay: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.stringFromDate(self)
    }
    
    // month
    var month: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.stringFromDate(self)
    }
    
    // month - Number
    var monthNum: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M"
        return dateFormatter.stringFromDate(self)
    }
    
    // week day
    var date: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter.stringFromDate(self)
    }
    
    // hour
    var hour: String {
        get {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH"
            
            if self.AMPM == "PM" {
                return String(stringInterpolationSegment: Int(dateFormatter.stringFromDate(self))! - 12)
            } else {
                return dateFormatter.stringFromDate(self)
            }
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
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "mm"
        return dateFormatter.stringFromDate(self)
    }
    
    var second: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "ss"
        return dateFormatter.stringFromDate(self)
    }
    
    // AM & PM
    var AMPM: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "a"
        return dateFormatter.stringFromDate(self)
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
