//
//  ViewController.swift
//  lemmenap
//
//  Created by Sarvesh on 11/10/18.
//  Copyright © 2018 Sarvesh. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftySound //https://cocoapods.org/pods/SwiftySound
import MediaPlayer
import CoreData
import UserNotifications


class HomeViewController: UIViewController, NewSoundSelectedDelegate {
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var fifteenMinutesButton: UIButton!
    @IBOutlet weak var twentyMinutesButton: UIButton!
    @IBOutlet weak var thirtyMinutesButton: UIButton!
    @IBOutlet weak var fourtyFiveMinutesButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    

    var setSleepDuration: Int = 5 {
        didSet{
            durationLabel.text = "\(setSleepDuration) minutes"
            setSleepDurationInSeconds = setSleepDuration * 60
        }
    }
    
    var timer = Timer()
        // timer made using https://medium.com/ios-os-x-development/build-an-stopwatch-with-swift-3-0-c7040818a10f
    static var timerRunning: Bool = false
    
    var setSleepDurationInSeconds = 300
    var sleepStartTime: Date?
    var sleepEndTime: Date?
    
    var presetButtonArray: [UIButton]?
    var currentButton: UIButton?
    
    var alarmSoundName: String?
    var alarmRepeat: Int?
    var alarmSoundUrl: URL?
    var alarmSound: Sound?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        durationSlider.setValue(5, animated: false)
        durationSlider.isContinuous = false
        durationLabel.text = "\(setSleepDuration) minutes"
        Sound.category = .playback
        
        presetButtonArray = [fifteenMinutesButton, twentyMinutesButton, thirtyMinutesButton, fourtyFiveMinutesButton]
        
        removeTabbarItemsText()
        updatePreferences()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
    }
    
    @objc func willEnterBackground(){
        if HomeViewController.timerRunning {
        sleepEndTime = Date()
        saveEntry(sleepStart: sleepStartTime!, sleepEnd: sleepEndTime!)
            print("saved entry when abruptly closed")
        } else {
            print("did not abruptly close, no entry saved")
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if !startButton.isSelected {
        updateQuoteLabel()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    func soundSelected(){
        updatePreferences()
    }
    

    
    func updatePreferences(){
        alarmSoundName = UserDefaults.standard.string(forKey: "alarmSoundName") ?? "calm"
        alarmRepeat =  UserDefaults.standard.integer(forKey: "alarmRepeat")
        alarmSoundUrl = Bundle.main.url(forResource: alarmSoundName, withExtension: "mp3")
        alarmSound = Sound(url: alarmSoundUrl!)
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    
    
    func updateQuoteLabel(){
        let facts = Quotes()
        let quotes = Quotes()
        let randomNumber = arc4random_uniform(2)
        
        if randomNumber == 0 {
        let factsRandomNumber = arc4random_uniform(UInt32(facts.factsArray.count))
        quoteLabel.text = "\(facts.factsArray[Int(factsRandomNumber)])"
        } else if randomNumber == 1{
        let quotesRandomNumber = arc4random_uniform(UInt32(quotes.quotesArray.count))
        quoteLabel.text = "\(quotes.quotesArray[Int(quotesRandomNumber)])"
    }
        
    }
    
    func testFunction(duration: NSNumber){
        print("Siri shortcut run successfully")
    }
    
    
    @IBAction func presetTimeSelected(_ sender: UIButton) {
        
        for button in presetButtonArray! {
            if button != sender {
            button.isSelected = false
            }
        }

        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            currentButton = sender
            if sender.tag == 0 {
                setSleepDuration = 15
                durationSlider.setValue(15, animated: true)
            } else if sender.tag == 1 {
                setSleepDuration = 20
                durationSlider.setValue(20, animated: true)
            } else if sender.tag == 2 {
                setSleepDuration = 30
                durationSlider.setValue(30, animated: true)
            } else if sender.tag == 3 {
                setSleepDuration = 45
                durationSlider.setValue(45, animated: true)
            }
        } else {
            setSleepDuration = 5
            durationSlider.setValue(5, animated: true)
            currentButton = nil
        }
        print(setSleepDuration)
    }

    @IBAction func durationSliderValueChanged(_ sender: Any) {
        
        for button in presetButtonArray! {
                button.isSelected = false
        }
        
        currentButton = nil
        
        setSleepDuration = Int(durationSlider.value)
        print(setSleepDuration)
    }
    
    
    @IBAction func startStopButtonTapped(_ sender: Any) {
        startButton.isSelected = !startButton.isSelected
        //UIApplication.shared.isIdleTimerDisabled = true
        if startButton.isSelected{
            UIView.animate(withDuration: 0.3) {
                self.startButton.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
            }
            
            for button in presetButtonArray! {
                
                button.isEnabled = false
            }
            
            currentButton?.backgroundColor = currentButton?.selectedColor
            currentButton?.setTitleColor(.black, for: .normal)
            
            durationSlider.isEnabled = false
            sleepStartTime = Date()
            Sound.play(file: "empty", fileExtension: "mp3", numberOfLoops: 0)
            runTimer()
            HomeViewController.timerRunning = true
            print("timer running set to true")
            BgFunctionalityAlert()
            
        } else {
           Sound.stopAll()
            
            UIView.animate(withDuration: 0.3) {
                self.startButton.transform = CGAffineTransform.identity
            }
            sleepEndTime = Date()
            timer.invalidate()
            HomeViewController.timerRunning = false
            saveEntry(sleepStart: sleepStartTime!, sleepEnd: sleepEndTime!)
            resetUI()
        }

       
    }
    
    
    func saveEntry(sleepStart: Date, sleepEnd: Date){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "SleepEntryDetail", in: managedContext)!
        let sleepEntry = NSManagedObject(entity: entity, insertInto: managedContext)
        sleepEntry.setValue(sleepStart, forKey: "sleepStart")
        sleepEntry.setValue(sleepEnd, forKey: "sleepEnd")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save sleep entry. \(error), \(error.userInfo)")
        }
        
        
    }
    
    func resetUI(){
        //UIApplication.shared.isIdleTimerDisabled = false
        
        
        for button in presetButtonArray! {
            button.isSelected = false
        }
        
        for button in presetButtonArray! {
            button.isEnabled = true
        }
        
        currentButton?.backgroundColor = UIColor.black
        currentButton?.setTitleColor(.white, for: .normal)
        currentButton = nil
        
        durationSlider.isEnabled = true
        durationSlider.setValue(5, animated: true)
        setSleepDuration = 5
        quoteLabel.font = quoteLabel.font.withSize(18)
        updateQuoteLabel()
        print("timer stopped")
    }
    
    
    func runTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(HomeViewController.updateTimer)), userInfo: nil, repeats: true)
    }

    
    @objc func updateTimer(){
        if setSleepDurationInSeconds < 1 {
            Sound.stopAll()
            timer.invalidate()
            HomeViewController.timerRunning = false
            quoteLabel.text = "Wake Up!"
            playAlarm()
        } else {
        setSleepDurationInSeconds -= 1
        quoteLabel.font = quoteLabel.font.withSize(35)
        quoteLabel.text = timeString(time: TimeInterval(setSleepDurationInSeconds))
        }
    }
    
    func timeString(time: TimeInterval) -> String {
        let minutes = Int(time)/60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    func playAlarm() {
        MPVolumeView.setVolume(UserDefaults.standard.float(forKey: "alarmVolume"))
        alarmSound?.play(numberOfLoops: alarmRepeat!, completion: { (completed) in
            self.resetUI()
            self.sleepEndTime = Date()
            self.startButton.isSelected = false
            UIView.animate(withDuration: 0.3) {
            self.startButton.transform = CGAffineTransform.identity
            }
            self.saveEntry(sleepStart: self.sleepStartTime!, sleepEnd: self.sleepEndTime!)
        })
    }
    
    func removeTabbarItemsText() {
        if let items = tabBarController?.tabBar.items {
            for item in items {
                item.title = ""
                item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0);
            }
        }
    }
    
    func BgFunctionalityAlert(){
        let doNotShowAgain = UserDefaults.standard.bool(forKey: "DoNotShowAgain")
        if doNotShowAgain  {
            print("Background Functionality Notificaion Turned Off")
        } else {
            print("Bg functionality notfication shown")
            
            
            let alert = UIAlertController(title: "Background Functionality", message: "This app is not designed to run in the background. Set the desired nap time and lock screen.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            let action2 = UIAlertAction(title: "Do not show again", style: .default) { (action) in
                UserDefaults.standard.set(true, forKey: "DoNotShowAgain")
            }
            alert.addAction(action)
            alert.addAction(action2)
            present(alert, animated: true, completion: nil)
            
        }
    }
    
}

extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            slider?.value = volume;
        }
    }
}

