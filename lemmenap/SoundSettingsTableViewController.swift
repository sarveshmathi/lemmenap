//
//  SoundSettingsTableViewController.swift
//  lemmenap
//
//  Created by Sarvesh on 15/10/18.
//  Copyright © 2018 Sarvesh. All rights reserved.
//

import UIKit
import MediaPlayer
import UserNotifications

class SoundSettingsTableViewController: UITableViewController {

    //@IBOutlet weak var myVolumeViewParentView: UIView!
   
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var numberOfLoopsStepper: UIStepper!
    @IBOutlet weak var numberOfLoopsLabel: UILabel!
    @IBOutlet weak var alarmVolumeSlider: UISlider!
    @IBOutlet weak var datePickerOne: UIDatePicker!
    @IBOutlet weak var datePickerTwo: UIDatePicker!
    @IBOutlet weak var datePickerThree: UIDatePicker!
    @IBOutlet weak var datePickerFour: UIDatePicker!
    @IBOutlet weak var reminderLabelOne: UILabel!
    @IBOutlet weak var reminderLabelTwo: UILabel!
    @IBOutlet weak var reminderLabelThree: UILabel!
    @IBOutlet weak var reminderLabelFour: UILabel!
    @IBOutlet weak var reminderSwitchOne: UISwitch!
    @IBOutlet weak var reminderSwitchTwo: UISwitch!
    @IBOutlet weak var reminderSwitchThree: UISwitch!
    @IBOutlet weak var reminderSwitchFour: UISwitch!
    
    
    var numberOfLoops: Int?
    var songName: String?
    var alarmVolume: Float?
    var reminderPickerOneIsEnabled: Bool = false {
        didSet {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    var reminderPickerTwoIsEnabled: Bool = false {
        didSet {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    var reminderPickerThreeIsEnabled: Bool = false {
        didSet {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    var reminderPickerFourIsEnabled: Bool = false {
        didSet {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.delaysContentTouches = false
        
//        myVolumeViewParentView.backgroundColor = UIColor.clear
//        let myVolumeView = MPVolumeView(frame: myVolumeViewParentView.bounds)
//        myVolumeViewParentView.addSubview(myVolumeView)
        
        initialiseDatePickerTextColor()
        initialiseReminderSettings()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        updatePreferences()
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { (notifications) in
            print("Count: \(notifications.count)")
            for item in notifications {
                print(item.content)
            }
        }
        
    }
    
    func updatePreferences(){
        songName = UserDefaults.standard.string(forKey: "alarmSoundName") ?? "calm"
        songNameLabel.text = songName
        numberOfLoops = UserDefaults.standard.integer(forKey: "alarmRepeat")
        numberOfLoopsStepper.value = Double(numberOfLoops!)
        numberOfLoopsLabel.text = "\(numberOfLoops ?? 0) times"
        alarmVolume = UserDefaults.standard.float(forKey: "alarmVolume")
        alarmVolumeSlider.value = alarmVolume!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch indexPath {
        case [3,0]:
            reminderPickerOneIsEnabled = !reminderPickerOneIsEnabled
        case [3,2]:
            reminderPickerTwoIsEnabled = !reminderPickerTwoIsEnabled
        case [3,4]:
            reminderPickerThreeIsEnabled = !reminderPickerThreeIsEnabled
        case [3,6]:
            reminderPickerFourIsEnabled = !reminderPickerFourIsEnabled
        default:
            break
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch (indexPath.section, indexPath.row) {
        case (3,1):
            if reminderPickerOneIsEnabled {
                return 216
            } else if !reminderPickerOneIsEnabled {
                return 0 }
        case (3,3):
            if reminderPickerTwoIsEnabled {
                return 216
            } else if !reminderPickerTwoIsEnabled {
                return 0 }
        case (3,5):
            if reminderPickerThreeIsEnabled {
                return 216
            } else if !reminderPickerThreeIsEnabled {
                return 0 }
        case (3,7):
            if reminderPickerFourIsEnabled {
                return 216
            } else if !reminderPickerFourIsEnabled {
                return 0
            }
        default:
            return 40
        }
        return 40
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        for view in tableView.subviews {
            if view is UIScrollView {
                (view as? UIScrollView)!.delaysContentTouches = false
                break
            }
        }
        return 1
    }
   
    @IBAction func stepperValueChanged(_ sender: Any) {
        
        numberOfLoops = Int(numberOfLoopsStepper.value)
        if numberOfLoops == 1 {
            numberOfLoopsLabel.text = "\(numberOfLoops ?? 0) time"
        } else {
            numberOfLoopsLabel.text = "\(numberOfLoops ?? 0) times"
        }
  
        UserDefaults.standard.set(numberOfLoops, forKey: "alarmRepeat")
    }
    
    
    @IBAction func alarmVolumeChanged(_ sender: Any) {
        
        alarmVolume = alarmVolumeSlider.value
        UserDefaults.standard.set(alarmVolume, forKey: "alarmVolume")
    }
    
    func initialiseReminderSettings(){
        reminderSwitchOne.isOn = UserDefaults.standard.bool(forKey: "ReminderOneSwitch")
        reminderSwitchTwo.isOn = UserDefaults.standard.bool(forKey: "ReminderTwoSwitch")
        reminderSwitchThree.isOn = UserDefaults.standard.bool(forKey: "ReminderThreeSwitch")
        reminderSwitchFour.isOn = UserDefaults.standard.bool(forKey: "ReminderFourSwitch")
        
        reminderLabelOne.text = dateFormatter(date: UserDefaults.standard.object(forKey: "ReminderOne") as? Date ?? stringToDate(stringDate: "11:00"))
        reminderLabelTwo.text = dateFormatter(date: UserDefaults.standard.object(forKey: "ReminderTwo") as? Date ?? stringToDate(stringDate: "13:00"))
        reminderLabelThree.text = dateFormatter(date: UserDefaults.standard.object(forKey: "ReminderThree") as? Date ?? stringToDate(stringDate: "15:00"))
        reminderLabelFour.text = dateFormatter(date: UserDefaults.standard.object(forKey: "ReminderFour") as? Date ?? stringToDate(stringDate: "17:00"))
    }
    
    func loadReminder(reminderNumber: String, switchNumber: UISwitch, defaultTime: String){
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Time for a nap?"
        content.body = "Take a revitalising nap and conquer the day"
        content.sound = UNNotificationSound.default
        
        let reminderTimeInDate = UserDefaults.standard.object(forKey: reminderNumber)
        let reminderTime = Calendar.current.dateComponents([.hour, .minute], from: reminderTimeInDate as? Date ?? stringToDate(stringDate: defaultTime))
        print(reminderTime)
        let triggerTime = reminderTime
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerTime, repeats: true)
        let identifier = reminderNumber
        
        if switchNumber.isOn {
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            center.add(request, withCompletionHandler: nil)
        } else if !switchNumber.isOn {
            center.removePendingNotificationRequests(withIdentifiers: [reminderNumber])
        }
    }
    
    @IBAction func reminderSwitchOne(_ sender: Any) {
        UserDefaults.standard.set(reminderSwitchOne.isOn, forKey: "ReminderOneSwitch")
        loadReminder(reminderNumber: "ReminderOne", switchNumber: reminderSwitchOne, defaultTime: "11:00")
    }
    
    @IBAction func reminderSwitchTwo(_ sender: Any) {
        UserDefaults.standard.set(reminderSwitchTwo.isOn, forKey: "ReminderTwoSwitch")
        loadReminder(reminderNumber: "ReminderTwo", switchNumber: reminderSwitchTwo, defaultTime: "13:00")
    }
    
    @IBAction func reminderSwitchThree(_ sender: Any) {
        UserDefaults.standard.set(reminderSwitchThree.isOn, forKey: "ReminderThreeSwitch")
        loadReminder(reminderNumber: "ReminderThree", switchNumber: reminderSwitchThree, defaultTime: "15:00")
    }
    
    @IBAction func reminderSwitchFour(_ sender: Any) {
        UserDefaults.standard.set(reminderSwitchFour.isOn, forKey: "ReminderFourSwitch")
        loadReminder(reminderNumber: "ReminderFour", switchNumber: reminderSwitchFour, defaultTime: "17:00")
    }
    
    @IBAction func datePickerOne(_ sender: Any) {
        let datePicked = datePickerOne.date
        UserDefaults.standard.set(datePicked, forKey: "ReminderOne")
        reminderLabelOne.text = dateFormatter(date: datePicked)
        loadReminder(reminderNumber: "ReminderOne", switchNumber: reminderSwitchOne, defaultTime: "11:00")
    }
    
    @IBAction func datePickerTwo(_ sender: Any) {
        reminderLabelTwo.text = dateFormatter(date: datePickerTwo.date)
        let datePicked = datePickerTwo.date
        UserDefaults.standard.set(datePicked, forKey: "ReminderTwo")
        loadReminder(reminderNumber: "ReminderTwo", switchNumber: reminderSwitchTwo, defaultTime: "13:00")
    }
    
    @IBAction func datePickerThree(_ sender: Any) {
        reminderLabelThree.text = dateFormatter(date: datePickerThree.date)
        let datePicked = datePickerThree.date
        UserDefaults.standard.set(datePicked, forKey: "ReminderThree")
        loadReminder(reminderNumber: "ReminderThree", switchNumber: reminderSwitchThree, defaultTime: "15:00")
    }
    
    @IBAction func datePickerFour(_ sender: Any) {
        reminderLabelFour.text = dateFormatter(date: datePickerFour.date)
        let datePicked = datePickerFour.date
        UserDefaults.standard.set(datePicked, forKey: "ReminderFour")
        loadReminder(reminderNumber: "ReminderFour", switchNumber: reminderSwitchFour, defaultTime: "17:00")
    }
    
    func initialiseDatePickerTextColor(){
        datePickerOne.setValue(UIColor.white, forKey: "textColor")
        
        datePickerTwo.setValue(UIColor.white, forKey: "textColor")
        
        datePickerThree.setValue(UIColor.white, forKey: "textColor")
        
        datePickerFour.setValue(UIColor.white, forKey: "textColor")
        
    }
    
    func dateFormatter(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        return (dateFormatter.string(from: date))
    }
    
    func stringToDate(stringDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return (dateFormatter.date(from: stringDate)!)
        
    }
    
    
}


