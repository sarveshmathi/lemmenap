//
//  SleepHistoryTableViewController.swift
//  lemmenap
//
//  Created by Sarvesh on 11/10/18.
//  Copyright © 2018 Sarvesh. All rights reserved.
//

import UIKit
import CoreData

class SleepHistoryTableViewController: UITableViewController {
    
    var sleepHistory: [NSManagedObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationController!.navigationBar.tintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SleepEntryDetail")
        let sort = NSSortDescriptor(key: "sleepStart", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            sleepHistory = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch data. \(error), \(error.userInfo)")
        }
   
        tableView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sleepHistory?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SleepHistoryCell", for: indexPath)
        
        
        let sleepDetail = sleepHistory![indexPath.row]
        
        let sleepDuration = (sleepDetail.value(forKeyPath: "sleepEnd") as! Date).timeIntervalSince(sleepDetail.value(forKeyPath: "sleepStart") as! Date)
        
        cell.textLabel?.text = "\(dateFormatter(date: (sleepDetail.value(forKeyPath: "sleepStart") as! Date)))"
        cell.detailTextLabel?.text = "Duration: \(timeString(time: sleepDuration))"
        
        return cell
    }
    
    
    
    func dateFormatter(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy '-' h:mm a"
         //http://nsdateformatter.com useful dataformatter resource
        return dateFormatter.string(from:date)
    }
    
    func timeString(time: TimeInterval) -> String {
        let hours = Int(time)/3600
        let minutes = Int(time)/60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }

   
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
   
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let sleepEntry = sleepHistory![indexPath.row]
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if editingStyle == .delete {
            
            managedContext.delete(sleepEntry)
            do {
               try managedContext.save()
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
            
            // Delete the row from the data source
            sleepHistory?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            
        }
    }
    

   

 

}
