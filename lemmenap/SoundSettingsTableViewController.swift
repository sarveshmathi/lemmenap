//
//  SoundSettingsTableViewController.swift
//  lemmenap
//
//  Created by Sarvesh on 15/10/18.
//  Copyright © 2018 Sarvesh. All rights reserved.
//

import UIKit
import MediaPlayer

class SoundSettingsTableViewController: UITableViewController {

    @IBOutlet weak var myVolumeViewParentView: UIView!
   
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var numberOfLoopsStepper: UIStepper!
    @IBOutlet weak var numberOfLoopsLabel: UILabel!
    
    var numberOfLoops: Int?
    var songName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.delaysContentTouches = false
        
        myVolumeViewParentView.backgroundColor = UIColor.clear
        let myVolumeView = MPVolumeView(frame: myVolumeViewParentView.bounds)
        myVolumeViewParentView.addSubview(myVolumeView)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        updatePreferences()
    }
    
    func updatePreferences(){
        songName = UserDefaults.standard.string(forKey: "alarmSoundName") ?? "cool"
        songNameLabel.text = songName
        numberOfLoops = UserDefaults.standard.integer(forKey: "alarmRepeat")
        numberOfLoopsStepper.value = Double(numberOfLoops!)
        numberOfLoopsLabel.text = "\(numberOfLoops ?? 0) times"
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
}
