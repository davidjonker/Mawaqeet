//
//  MainViewController.swift
//  Mawaqeet
//
//  Created by super on 6/1/16.
//  Copyright © 2016 super. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LocationServiceDelegate {

    var c_cityName = ""
    var c_countryName = ""
    var c_location: NSDictionary = [:]
    var datePrayerTimes:[AKPrayerTime.TimeNames: AnyObject] = [:]
    let dayTopColor = CommonUtils.colorWithHexString("D85A47")
    let dayBottomColor = CommonUtils.colorWithHexString("DA2F24")
    let dayToTopColor = CommonUtils.colorWithHexString("955EAB")
    let dayToBottomColor = CommonUtils.colorWithHexString("973157")
    let nightTopColor = CommonUtils.colorWithHexString("2D6481")
    let nightBottomColor = CommonUtils.colorWithHexString("173382")
    let nightToTopColor = CommonUtils.colorWithHexString("314561")
    let nightToBottomColor = CommonUtils.colorWithHexString("192563")
    var saudiArabiaNames = ["China", "Saudi Arabia", "S.A.", "المملكة العربية السعودية", "حدود المملكة العربية السعودية" ]
    var storeFlag = false
    var isInSaudiArabia = false
    var gradient : CAGradientLayer?
    var toColors : AnyObject?
    var fromColors : AnyObject?
    var storeClosedPrayerText = "FAJR"
    var day = true
    var previousFlag = true
    var prayerTimer:NSTimer = NSTimer()
    var storeTimer:NSTimer = NSTimer()
    var storeOpenTime:NSDate = NSDate()
    var currentPrayerStoreTime = NSDate()
    var nextPrayerTime:NSDate = NSDate()
    var currentPrayerTime:NSDate = NSDate()
    var nextPrayerName = ""
    
    @IBOutlet weak var contactBtn: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var aboutMainView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var prayerTimeTableView: UITableView!
    @IBOutlet weak var weekDayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nextPrayerView: UIView!
    @IBOutlet weak var nextPrayerNameLabel: UILabel!
    @IBOutlet weak var nextPrayerCountTimeLabel: UILabel!
    @IBOutlet weak var sunRiseView: UIView!
    @IBOutlet weak var sunRiseTimeLabel: UILabel!
    @IBOutlet weak var	 sunSetView: UIView!
    @IBOutlet weak var sunSetTimeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var storeView: UIView!
    @IBOutlet weak var storeOpenView: UIView!
    @IBOutlet weak var storeCloseView: UIView!
    @IBOutlet weak var sunView: UIView!
    @IBOutlet weak var storeRemainingTime: UILabel!
    @IBOutlet weak var storeClosedPrayerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.aboutMainView.contentSize = CGSizeMake(self.view.frame.size.width, self.contactBtn.frame.origin.y + self.contactBtn.frame.size.height)
        self.isInSaudiArabia = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.appDidEnterBackground), name: "appDidEnterBackground", object: nil)
        
        // Set Weekday and Date Label.
        self.setWeekDayAndDate()
        
        // Disable scroll, disable selection and hide seperator line in table view.
        self.disableTableSettings()
        
        // Set Location Delegate.
        LocationService.sharedInstance.delegate = self
        
        // Start App
        self.startApp()
        
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func toggleFromDayToNight() {
        day = !day
        
        if day {
            self.gradient!.colors = [dayTopColor.CGColor, dayBottomColor.CGColor]
            toColors = [dayToTopColor.CGColor, dayToBottomColor.CGColor]
        } else {
            self.gradient!.colors = [nightTopColor.CGColor, nightBottomColor.CGColor]
            toColors = [nightToTopColor.CGColor, nightToBottomColor.CGColor]
        }
        
        gradient!.removeAnimationForKey("animateGradient")                      // cancel the animation
        animateLayer()                                                          // start animation
    }
    
    func animateLayer(){
        
        self.fromColors = self.gradient!.colors!
        self.gradient!.colors = self.toColors as? [AnyObject]
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "colors")
        animation.delegate = self
        animation.fromValue = fromColors
        animation.toValue = toColors
        animation.duration = 3.0
        animation.removedOnCompletion = true
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.delegate = self
        
        self.gradient!.addAnimation(animation, forKey:"animateGradient")
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        
        if flag {
//            swap(&toColors, &fromColors)
            toColors = fromColors;
            fromColors = gradient!.colors!
            animateLayer()
        }
    }

    func appDidEnterBackground() {
        exit(0)
    }
    
    func startApp(){
        // Check Internet Connection
        let status = Reach().connectionStatus()
        switch status {
        case .Unknown, .Offline:
            print("Not connected")
            
            self.showProgress()
            
            if let cityName = defaults.valueForKey("c_cityName") as! String! {
                let ac = UIAlertController(title: "Error", message: "Your device is currently offline. We will use your previous saved location.", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default){ (action) in
                    self.c_cityName = cityName
                    self.c_countryName = NSUserDefaults.standardUserDefaults().valueForKey("c_countryName") as! String!
                    self.c_location = defaults.valueForKey("c_location") as! NSDictionary!
                    self.setCityAndCountryName(self.c_cityName, countryString: self.c_countryName)
                }
                ac.addAction(okAction)
                self.presentViewController(ac, animated: true, completion: nil)
            }
            else{
                let ac = UIAlertController(title: "Error", message: "Your device is offline and never connected internet with this app before. Please try again once you've connected to internet", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default){ (action) in
                    self.hideProgress()
                    exit(0)
                }
                ac.addAction(okAction)
                self.presentViewController(ac, animated: true, completion: nil)
                
            }
            break
        case .Online(.WWAN), .Online(.WiFi):
            print("Connected to Internet")
            self.showProgress()
            LocationService.sharedInstance.startUpdatingLocation()
            break
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: LocationService Delegate
    func tracingLocation(currentLocation: CLLocation) {
        let lat = currentLocation.coordinate.latitude
        let lon = currentLocation.coordinate.longitude
        
        print("latitude, longtitude", lat, lon)
        LocationService.sharedInstance.stopUpdatingLocation()
        // Save Location to NSUserDefaults.
        c_location = ["lat": lat, "lon": lon]
        defaults.setObject(c_location, forKey: "c_location")
        // Reverse Geo-Coordinate
        self.getAddressFromGeocodeCoordinate()
    }
    
    func tracingLocationDidFailWithError(error: NSError) {
        print("tracing Location Error : \(error.description)")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! PrayerTableViewCell
        let currentDate:NSDate = NSDate()
        if self.datePrayerTimes.count != 0{
            switch indexPath.row {
            case 0:
                cell.prayerName.text = "FAJR"
                let prayerTime = self.datePrayerTimes[.Fajr] as! NSDate!
                let prayerString = prayerTime.dateToString()
                cell.prayerTime.text =  prayerString.uppercaseString
                let isPassed = prayerTime.isGreaterThanDate(currentDate)
                cell.isPrayerFinishedLine.hidden = isPassed
                let prayerNextTime = self.datePrayerTimes[.Dhuhr] as! NSDate!
                if !isPassed {
                    self.nextPrayerTime = prayerNextTime
                    self.nextPrayerName = "DHUHR"
                }
                else{
                    self.nextPrayerName = "FAJR"
                }
                cell.prayerDuration.text = prayerTime.durationUntilNextPrayer(prayerNextTime)
                cell.isPrayerFinishedLine.tag = 2000
            case 1:
                cell.prayerName.text = "DHUHR"
                let prayerTime = self.datePrayerTimes[.Dhuhr] as! NSDate!
                let prayerString = prayerTime.dateToString()
                cell.prayerTime.text =  prayerString.uppercaseString
                let isPassed = prayerTime.isGreaterThanDate(currentDate)
                cell.isPrayerFinishedLine.hidden = isPassed
                let prayerNextTime = self.datePrayerTimes[.Asr] as! NSDate!
                if !isPassed {
                    self.nextPrayerTime = prayerNextTime
                    self.nextPrayerName = "ASR"
                }
                cell.prayerDuration.text = prayerTime.durationUntilNextPrayer(prayerNextTime)
                cell.isPrayerFinishedLine.tag = 2001
            case 2:
                cell.prayerName.text = "ASR"
                let prayerTime = self.datePrayerTimes[.Asr] as! NSDate!
                let prayerString = prayerTime.dateToString()
                cell.prayerTime.text =  prayerString.uppercaseString
                let isPassed = prayerTime.isGreaterThanDate(currentDate)
                cell.isPrayerFinishedLine.hidden = isPassed
                let prayerNextTime = self.datePrayerTimes[.Maghrib] as! NSDate!
                if !isPassed {
                    self.nextPrayerTime = prayerNextTime
                    self.nextPrayerName = "MAGHRIB"
                }
                cell.prayerDuration.text = prayerTime.durationUntilNextPrayer(prayerNextTime)
                cell.isPrayerFinishedLine.tag = 2002
            case 3:
                cell.prayerName.text = "MAGHRIB"
                let prayerTime = self.datePrayerTimes[.Maghrib] as! NSDate!
                let prayerString = prayerTime.dateToString()
                cell.prayerTime.text =  prayerString.uppercaseString
                let isPassed = prayerTime.isGreaterThanDate(currentDate)
                cell.isPrayerFinishedLine.hidden = isPassed
                let prayerNextTime = self.datePrayerTimes[.Isha] as! NSDate!
                if !isPassed {
                    self.nextPrayerTime = prayerNextTime
                    self.nextPrayerName = "ISHA"
                }
                cell.prayerDuration.text = prayerTime.durationUntilNextPrayer(prayerNextTime)
                cell.isPrayerFinishedLine.tag = 2003
            case 4:
                cell.prayerName.text = "ISHA"
                let prayerTime = self.datePrayerTimes[.Isha] as! NSDate!
                let prayerString = prayerTime.dateToString()
                cell.prayerTime.text =  prayerString.uppercaseString
                let isPassed = prayerTime.isGreaterThanDate(currentDate)
                cell.isPrayerFinishedLine.hidden = isPassed
                if !isPassed {
                    self.nextPrayerName = "Midnight"
                }
                cell.isPrayerFinishedLine.tag = 2004
                
            default:
                print("default")
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 4 && self.datePrayerTimes.count != 0) {
            let date = NSDate()
            for prayertime in self.datePrayerTimes {
                if let currentPrayerTime = prayertime.1 as? NSDate {
                    if date.isGreaterThanDate(currentPrayerTime) {
                        self.storeClosedPrayerText = prayertime.0.toString().uppercaseString
                    }
                    let prayerOpenTime = currentPrayerTime.dateByAddingTimeInterval(35.0*60.0)
                    if date.isGreaterThanDate(currentPrayerTime) && date.isLessThanDate(prayerOpenTime) {
                        currentPrayerStoreTime = currentPrayerTime
                        self.storeFlag = true
                        break
                    }
                }
            }
            if self.storeFlag && self.isInSaudiArabia {
                self.showStoreTime()
                self.storeFlag = false
            }
            animateBackground()
            if self.nextPrayerName == "Midnight"{
                self.nextPrayerNameLabel.font = UIFont(name: (self.nextPrayerNameLabel?.font.fontName)!, size: 28)
                self.nextPrayerCountTimeLabel.font = UIFont(name: (self.nextPrayerCountTimeLabel?.font.fontName)!, size: 20)
                self.nextPrayerNameLabel.text = "God Bless"
                self.nextPrayerCountTimeLabel.text = "Timers restart at midnight"
            }
            else{
                self.nextPrayerNameLabel.font = UIFont(name: (self.nextPrayerNameLabel?.font.fontName)!, size: 37)
                self.nextPrayerCountTimeLabel.font = UIFont(name: (self.nextPrayerCountTimeLabel?.font.fontName)!, size: 37)
                setNextPrayerTimeLabel()
            }
            self.prayerTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(MainViewController.nextPrayerTimerFunction), userInfo: nil, repeats: true)
            self.hideProgress()
        }
    }
    
    func setNextPrayerTimeLabel() {
        self.nextPrayerNameLabel.text = self.nextPrayerName
    }
    
    func animateBackground() {
        let currentTime = NSDate()
        
        
        if currentTime.isGreaterThanDate(self.datePrayerTimes[.Sunrise] as! NSDate!) && currentTime.isLessThanDate(self.datePrayerTimes[.Sunset] as! NSDate!){
            day = true
        }
        else {
            day = false
        }
        // Animate Layer
        if (day) {
            fromColors = [dayTopColor.CGColor, dayBottomColor.CGColor]
            toColors = [dayToTopColor.CGColor, dayToBottomColor.CGColor]
        }
        else {
            fromColors = [nightTopColor.CGColor, nightBottomColor.CGColor]
            toColors = [nightToTopColor.CGColor, nightToBottomColor.CGColor]
        }
        
        gradient = CAGradientLayer()
        gradient!.colors = fromColors! as? [AnyObject]
        gradient!.frame = view.bounds
        self.view.layer.insertSublayer(gradient!, atIndex: 0)
        
        animateLayer()
    }
    
    func stopTimer(timer: NSTimer){
        timer.invalidate()
    }
    
    func showStoreTime() {
        print(self.storeClosedPrayerText)
        self.storeClosedPrayerLabel.text = self.storeClosedPrayerText
        self.storeOpenTime = currentPrayerStoreTime.dateByAddingTimeInterval(35.0 * 60.0)
        self.sunView.alpha = 1.0
        self.sunView.hidden = false
        UIView.animateWithDuration(1.5, animations: { () -> Void in
            self.sunView.alpha = 0.0
            },completion: { (finished: Bool) -> Void in
                self.sunView.hidden = true
                self.storeCloseView.hidden = false
                self.storeView.hidden = false
                self.storeView.alpha = 0.0
                self.storeCloseView.alpha = 0.0
                UIView.animateWithDuration(1.5, animations: { () -> Void in
                    self.storeView.alpha = 0.3
                    self.storeCloseView.alpha = 1.0
                    },completion: { (finished: Bool) -> Void in
                        
                        self.storeOpenView.alpha = 0.0
                        self.storeOpenView.hidden = false
                        UIView.animateKeyframesWithDuration(2, delay: 5, options: UIViewKeyframeAnimationOptions.CalculationModeLinear, animations: {() -> Void in
                            self.storeOpenView.alpha = 1.0
                            self.storeCloseView.alpha = 0.0
                            }, completion: {(finished: Bool) -> Void in
                                self.storeCloseView.hidden = true
                        })
                });
                
        });
        storeTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(MainViewController.storeTimerFunction), userInfo: nil, repeats: true)
    }
    func nextPrayerTimerFunction(){
        let currentDate:NSDate = NSDate()
        if self.nextPrayerName == "Midnight"{
            if currentDate.AMPM == "AM" {
                
                self.stopTimer(self.prayerTimer)
                self.showProgress()
                self.getPrayerTimes()
            }
        }
        else if self.nextPrayerName != "Midnight"{
            let difference = currentDate.compareWithPrayerDate(self.nextPrayerTime)
            self.nextPrayerCountTimeLabel.text = difference
            let currentTime = NSDate()
            if currentTime.isGreaterThanDate(self.datePrayerTimes[.Sunrise] as! NSDate!) && currentTime.isLessThanDate(self.datePrayerTimes[.Sunset] as! NSDate!){
                previousFlag = true
            }
            else {
                previousFlag = false
            }
            if previousFlag != day {
                self.toggleFromDayToNight()
            }
            if difference == "00:00:00" {
                if self.nextPrayerName == "FAJR"{
                    self.storeClosedPrayerText = "FAJR"
                    self.nextPrayerTime = self.datePrayerTimes[.Dhuhr] as! NSDate!
                    self.currentPrayerTime = self.datePrayerTimes[.Fajr] as! NSDate!
                    self.nextPrayerNameLabel.text = "DHUHR"
                    let finishedLine = self.view.viewWithTag(2000)
                    finishedLine?.hidden = false
                }
                else if self.nextPrayerName == "DHUHR"{
                    self.storeClosedPrayerText = "DHUHR"
                    self.nextPrayerTime = self.datePrayerTimes[.Asr] as! NSDate!
                    self.currentPrayerTime = self.datePrayerTimes[.Dhuhr] as! NSDate!
                    self.nextPrayerNameLabel.text = "ASR"
                    let finishedLine = self.view.viewWithTag(2001)
                    finishedLine?.hidden = false
                }
                else if self.nextPrayerName == "ASR"{
                    self.storeClosedPrayerText = "ASR"
                    self.nextPrayerTime = self.datePrayerTimes[.Maghrib] as! NSDate!
                    self.currentPrayerTime = self.datePrayerTimes[.Asr] as! NSDate!
                    self.nextPrayerNameLabel.text = "MAGHRIB"
                    let finishedLine = self.view.viewWithTag(2002)
                    finishedLine?.hidden = false
                }
                else if self.nextPrayerName == "MAGHRIB"{
                    self.storeClosedPrayerText = "MAGHRIB"
                    self.nextPrayerTime = self.datePrayerTimes[.Isha] as! NSDate!
                    self.currentPrayerTime = self.datePrayerTimes[.Maghrib] as! NSDate!
                    self.nextPrayerNameLabel.text = "ISHA"
                    let finishedLine = self.view.viewWithTag(2003)
                    finishedLine?.hidden = false
                }
                else{
                    self.storeClosedPrayerText = "ISHA"
                    self.currentPrayerTime = self.datePrayerTimes[.Isha] as! NSDate!
                    let finishedLine = self.view.viewWithTag(2004)
                    finishedLine?.hidden = false
                    self.nextPrayerName = "Midnight"
                    self.nextPrayerNameLabel.font = UIFont(name: (self.nextPrayerNameLabel?.font.fontName)!, size: 28)
                    self.nextPrayerCountTimeLabel.font = UIFont(name: (self.nextPrayerCountTimeLabel?.font.fontName)!, size: 20)
                    self.nextPrayerNameLabel.text = "God Bless"
                    self.nextPrayerCountTimeLabel.text = "Timers restart at midnight"
                }
                self.currentPrayerStoreTime = self.currentPrayerTime
                print(self.isInSaudiArabia)
                if self.isInSaudiArabia {
                    print("saudi arabia")
                    self.showStoreTime()
                }
            }
        }
    }
    
    func storeTimerFunction() {
        let currentStoreDate = NSDate()
        let difference = currentStoreDate.compareWithPrayerDate(self.storeOpenTime)
        if difference == "00:00:00" {
            UIView.animateWithDuration(1, animations: { () -> Void in
                self.storeView.alpha = 0.0
                self.storeOpenView.alpha = 0.0
                },completion: { (finished: Bool) -> Void in
                    self.storeView.hidden = true
                    self.storeOpenView.hidden = true
                    self.sunView.hidden = false
                    self.sunView.alpha = 0.0
                    UIView.animateWithDuration(1, animations: { () -> Void in
                        self.sunView.alpha = 1.0
                        },completion: { (finished: Bool) -> Void in
                            
                    });
                    
            });
        }
        self.storeRemainingTime.text = difference
    }
    
    // Set city and country
    
    func setCityAndCountryName(cityString: String, countryString: String) {
        self.cityLabel.text = cityString
        self.countryLabel.text = countryString
        if self.saudiArabiaNames.contains(self.c_cityName) || self.saudiArabiaNames.contains(self.c_countryName){
            self.isInSaudiArabia = true
        }
        self.getPrayerTimes()
    }
    
    
    func getPrayerTimes() {
        let prayerKit: AKPrayerTime = AKPrayerTime(lat: c_location.valueForKey("lat") as! Double, lng: c_location.valueForKey("lon") as! Double)
        prayerKit.calculationMethod = .Makkah
        prayerKit.asrJuristic = .Shafii
        prayerKit.outputFormat = .Time12
        prayerKit.outputFormat = .Date
        datePrayerTimes = prayerKit.getPrayerTimes()!
        
        // Set sun rise and sun set text
        setSunRiseAndSet()
        registerNotification()
        self.prayerTimeTableView.reloadData()
    }
    
    // Register Notification.
    func registerNotification() {
        if (NSUserDefaults.standardUserDefaults().objectForKey("appOpenedDate") == nil){
            NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey:"appOpenedDate")
            self.registerPrayerNotification()
            print("first time")
        }
        else{
            let cDate = NSDate()
            let appOpenedDate = NSUserDefaults.standardUserDefaults().objectForKey("appOpenedDate") as! NSDate
            if appOpenedDate.year != cDate.year || appOpenedDate.month != cDate.month || appOpenedDate.date != cDate.date {
                NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey:"appOpenedDate")
                self.registerPrayerNotification()
            }
        }
    }
    
    func registerPrayerNotification() {
        LocalNotificationHelper.sharedInstance().scheduleNotificationWithKey("FAJR", title: "Prayer Time", message: "It's FAJR Prayer Time", date: self.datePrayerTimes[.Fajr] as! NSDate!, soundName: UILocalNotificationDefaultSoundName, userInfo: nil)
        LocalNotificationHelper.sharedInstance().scheduleNotificationWithKey("DHUHR", title: "Prayer Time", message: "It's DHUHR Prayer Time", date: self.datePrayerTimes[.Dhuhr] as! NSDate!, soundName: UILocalNotificationDefaultSoundName, userInfo: nil)
        LocalNotificationHelper.sharedInstance().scheduleNotificationWithKey("ASR", title: "Prayer Time", message: "It's ASR Prayer Time", date: self.datePrayerTimes[.Asr] as! NSDate!, soundName: UILocalNotificationDefaultSoundName, userInfo: nil)
        LocalNotificationHelper.sharedInstance().scheduleNotificationWithKey("MAGHRIB", title: "Prayer Time", message: "It's MAGHRIB Prayer Time", date: self.datePrayerTimes[.Maghrib] as! NSDate!, soundName: UILocalNotificationDefaultSoundName, userInfo: nil)
        LocalNotificationHelper.sharedInstance().scheduleNotificationWithKey("ISHA", title: "Prayer Time", message: "It's ISHA Prayer Time", date: self.datePrayerTimes[.Isha] as! NSDate!, soundName: UILocalNotificationDefaultSoundName, userInfo: nil)
//        for prayerTime in self.datePrayerTimes {
//            let pTime = prayerTime.1 as? NSDate
//            LocalNotificationHelper.sharedInstance().scheduleNotificationWithKey(prayerTime.0.toString(), title: "Prayer Time.", message: "It's " + prayerTime.0.toString() + " Time.", date: pTime!, soundName: UILocalNotificationDefaultSoundName, userInfo: nil)
//        }
    }
    // Show Progress
    
    func showProgress() {
        self.loadingView.hidden = false
        self.mainView.hidden = true
        self.mainView.alpha = 1.0
        self.loadingView.alpha = 1.0
        self.activityIndicator.startAnimating()
    }
    
    // Hide Progress
    
    func hideProgress() {
        self.activityIndicator.stopAnimating()
        UIView.animateWithDuration(1.0, animations: {() -> Void in
            self.loadingView.alpha = 0.0
            }, completion: {(finished: Bool) -> Void in
                self.loadingView.hidden = true
                self.loadingView.alpha = 1.0
                self.mainView.alpha = 0.0
                self.mainView.hidden = false
                UIView.animateWithDuration(1.0, animations: {() -> Void in
                    self.mainView.alpha = 1.0
                })
        })
    }
    
    @IBAction func settingsBtnTapped(sender: UIButton) {
    }
    
    @IBAction func aboutBtnTapped(sender: UIButton) {
        let blurEffectView = UIVisualEffectView()
        blurEffectView.frame = self.mainView.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        self.mainView.addSubview(blurEffectView)
        self.aboutMainView.hidden = false
        UIView.animateWithDuration(1, animations: {() -> Void in
            blurEffectView.effect = UIBlurEffect(style: .Dark)
            self.mainView.addSubview(blurEffectView)
        })
    }
    
    @IBAction func closeAboutViewBtnTapped(sender: UIButton) {
        let blurEffectView = UIVisualEffectView()
        blurEffectView.frame = self.mainView.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        self.mainView.addSubview(blurEffectView)
        UIView.animateWithDuration(1, animations: {() -> Void in
            self.aboutMainView.alpha = 0
            }, completion: {(finished: Bool) -> Void in
                for subview in self.mainView.subviews {
                    if subview is UIVisualEffectView {
                        subview.removeFromSuperview()
                    }
                }
                self.aboutMainView.alpha = 1
                self.aboutMainView.hidden = true
        })
        
        
    }
    
    @IBAction func contactBtnTapped(sender: UIButton) {
        if let tirerackUrl = NSURL(string: "https://twitter.com/emad_alghamdi"){
            if (UIApplication.sharedApplication().openURL(tirerackUrl)){
                print("successfully opened")
            }
        }
    }
    
}
