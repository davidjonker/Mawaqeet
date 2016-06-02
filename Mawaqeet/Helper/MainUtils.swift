//
//  MainUtils.swift
//  Mawaqeet
//
//  Created by super on 6/1/16.
//  Copyright © 2016 super. All rights reserved.
//

import Foundation
import CoreLocation
let defaults = NSUserDefaults.standardUserDefaults()
extension MainViewController {
    
    // Set Weekday and Date Label.
    func setWeekDayAndDate() {
        let currentDate:NSDate = NSDate()
        // Get current date
        let weekDay = currentDate.weekDay  // Get week day
        let month = currentDate.month      // Get current Month
        let year = currentDate.year        // Get current Year
        let monthNum = currentDate.date    // Get current Date
        
        let dayString = "\(month) \(monthNum), \(year)"
        
        self.weekDayLabel.text = weekDay
        self.dateLabel.text = dayString
    }
    
    // Disable scroll, disable selection and hide seperator line in table view.
    func disableTableSettings() {
        self.prayerTimeTableView.allowsSelection = false
        self.prayerTimeTableView.scrollEnabled = false
        self.prayerTimeTableView.separatorStyle = .None
    }
    
    // Get address from geo-coordinate
    
    func getAddressFromGeocodeCoordinate() {
        let locationObj = CLLocation(latitude: c_location.valueForKey("lat") as! Double, longitude: c_location.valueForKey("lon") as! Double)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(locationObj, completionHandler: {(stuff, error)->Void in
            
            if (error != nil) {
                print("reverse geodcode fail: \(error!.localizedDescription)")
                self.c_cityName = "Can't get correct city"
                self.c_countryName = "Can't get correct country"
                self.setCityAndCountryName(self.c_cityName, countryString: self.c_countryName)
                return
            }
            
            if stuff!.count > 0 {
                let placemark = CLPlacemark(placemark: stuff![0] as CLPlacemark)
                // Get city info and set city text to label.
                if let currentCity = placemark.locality as String!{
                    defaults.setValue(currentCity, forKey: "c_cityName")
                    self.c_cityName = currentCity
                }
                else{
                    if let currentProvince = placemark.administrativeArea as String!{
                        defaults.setValue(currentProvince, forKey: "c_cityName")
                        self.c_cityName = currentProvince
                    }
                    else{
                        self.c_cityName = "Can't get correct city"
                        defaults.setValue("Didn't get correct city before.", forKey: "c_cityName")
                    }
                }
                
                // Get country info and set country text to label.
                if let currentCountry = placemark.country as String!{
                    defaults.setValue(currentCountry, forKey: "c_countryName")
                    self.c_countryName = currentCountry
                }
                else{
                    self.c_countryName = "Can't get correct country"
                    defaults.setValue("Didn't get correct country before.", forKey: "c_countryName")
                }
                self.setCityAndCountryName(self.c_cityName, countryString: self.c_countryName)
                
            }
            else {
                print("No Placemarks!")
                return
            }
            
        })
    }
    
    // Set sunrise and sun set
    func setSunRiseAndSet(){
        let sunRiseTime = self.datePrayerTimes[.Sunrise]
        let sunSetTime = self.datePrayerTimes[.Sunset]
        self.sunRiseTimeLabel.text = (sunRiseTime?.dateToString())!.uppercaseString
        self.sunSetTimeLabel.text = (sunSetTime?.dateToString())!.uppercaseString
    }
   
}

extension NSDate {
    func dateToString() -> String {
//        let returnString = "\(self.hour):\(self.minute) \(self.AMPM)"
        var returnString = String(format: "%02d:%02d", Int(self.hour)!, Int(self.minute)!)
        returnString = returnString + " \(self.AMPM)"
        return returnString
    }
}