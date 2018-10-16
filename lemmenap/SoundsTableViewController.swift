//
//  SoundsTableViewController.swift
//  lemmenap
//
//  Created by Sarvesh on 15/10/18.
//  Copyright © 2018 Sarvesh. All rights reserved.
//

import UIKit
import SwiftySound

class SoundsTableViewController: UITableViewController {
    
    var soundsArray: [String] = ["cool", "softwakeup"]
    var delegate: NewSoundSelectedDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDelegate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        Sound.stopAll()
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soundsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SoundNameCell", for: indexPath)
        
        let soundName = soundsArray[indexPath.row]
        cell.textLabel?.text = soundName

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
            Sound.stopAll()
            let sound = soundsArray[indexPath.row]
            Sound.play(file: sound, fileExtension: "wav", numberOfLoops: 0)
            UserDefaults.standard.setValue(sound, forKey: "alarmSoundName")
            delegate?.soundSelected()
        }
    
    
    
    func setUpDelegate(){
        let homeVC = tabBarController?.viewControllers?.first as! HomeViewController
        delegate = homeVC

    }
    

}

protocol NewSoundSelectedDelegate {
    func soundSelected()
}
