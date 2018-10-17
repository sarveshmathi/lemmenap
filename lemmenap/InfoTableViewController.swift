//
//  InfoTableViewController.swift
//  lemmenap
//
//  Created by Sarvesh on 16/10/18.
//  Copyright © 2018 Sarvesh. All rights reserved.
//

import UIKit

class InfoTableViewController: UITableViewController {
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        if UserDefaults.standard.bool(forKey: "notificationsEnabled"){
            notificationSwitch.isOn = true
        } else {
            notificationSwitch.isOn = false
        }
        
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 125
        case 1:
            return 250
        case 2:
            return 225
        default: return 40
        }
    }
    
    @IBAction func notificationSwitch(_ sender: Any) {
      
        let alertController = UIAlertController (title: "Enable/Disable Notifcations", message: "Go to Settings to toggle notification settings.", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    

}
