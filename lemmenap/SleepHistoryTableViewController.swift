//
//  SleepHistoryTableViewController.swift
//  lemmenap
//
//  Created by Sarvesh on 11/10/18.
//  Copyright © 2018 Sarvesh. All rights reserved.
//

import UIKit
import CoreData

class SleepHistoryTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var managedContext: NSManagedObjectContext?
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationController!.navigationBar.tintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        initialiseFetchedRequestsController()
        tableView.reloadData()
        
    }
    
    func initialiseFetchedRequestsController(){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SleepEntryDetail")
        //fetchRequest.fetchBatchSize = 20
        let sort = NSSortDescriptor(key: "sleepStart", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext!, sectionNameKeyPath: "sectionIdentifier", cacheName: nil) as? NSFetchedResultsController<NSFetchRequestResult>
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        
    }
    

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if let frc = fetchedResultsController {
            return frc.sections!.count
        }
        
        return 0
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SleepHistoryCell", for: indexPath)
        
        let sleepDetail = self.fetchedResultsController.object(at: indexPath) as! SleepEntryDetail
        
        let sleepDuration = (sleepDetail.sleepEnd as Date).timeIntervalSince(sleepDetail.sleepStart as Date)
        
        cell.textLabel?.text = "\(dateFormatter(date: (sleepDetail.sleepStart) as Date))"
        cell.detailTextLabel?.text = "Duration: \(timeString(time: sleepDuration))"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let sectionInfo = fetchedResultsController?.sections?[section] else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        let formatTemplate = DateFormatter.dateFormat(fromTemplate: "MMMM YYYY", options: 0, locale: NSLocale.current)
        formatter.dateFormat = formatTemplate ?? ""
        
        let numericSection: Int = Int(sectionInfo.name)!
        let year: Int = numericSection/1000
        let month: Int = numericSection - (year * 1000)
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        let date: Date? = Calendar.current.date(from: dateComponents)
        
        var titleString: String? = nil
        if let date = date {
            titleString = formatter.string(from: date)
        }
        
        return "\(titleString!) \nDaily Average: \(dailyAverageCalculator(section: section))"
    }
    
    func dailyAverageCalculator(section: Int) -> String {
        guard let sectionInfo = fetchedResultsController?.sections?[section] else {
            return ""
        }
        
        var dictionary = [String:TimeInterval]()
        
        for object in sectionInfo.objects! as! [SleepEntryDetail]{
            
            let diff = object.sleepEnd.timeIntervalSince(object.sleepStart as Date)
            
            let sleepStartString = dateFormatterForDailyAverage(date: object.sleepStart as Date)
            
            dictionary[sleepStartString, default: 0] +=  diff
        }
        
        var sectionSum:TimeInterval = 0
        var daysCount: Double = 0
        
        for entry in dictionary {
            sectionSum += entry.value
            daysCount += 1
        }
        
        let dailyAverage = sectionSum/daysCount
        let dailyAverageFormatted = timeString2(time: dailyAverage)
        
        return dailyAverageFormatted
        
    }
    
        override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
            view.tintColor = UIColor.darkGray
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = UIColor.white
            header.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            //header.textLabel?.text = header.textLabel?.text?.capitalized
        }
    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//
//        return 30
//    }
    
    func dateFormatterForDailyAverage(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY MMM dd"
        //http://nsdateformatter.com useful dataformatter resource
        return dateFormatter.string(from:date)
    }
    
    
    func dateFormatter(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM dd '-' h:mm a"
         //http://nsdateformatter.com useful dataformatter resource
        return dateFormatter.string(from:date)
    }
    
    func timeString2(time: TimeInterval) -> String {
        let hours = String(format: "%02i", Int(time)/3600)
        let minutes = String(format: "%02i", Int(time)/60 % 60)
        let seconds = String(format: "%02i", Int(time) % 60)
        
        if hours == "00" && minutes == "00" {
            return "\(seconds) seconds (Nap More 😉)"
        } else if hours == "00" {
            return "\(minutes)m"
        } else {
            return "\(hours)h \(minutes)m"
        }
    }

    func timeString(time: TimeInterval) -> String {
        let hours = String(format: "%02i", Int(time)/3600)
        let minutes = String(format: "%02i", Int(time)/60 % 60)
        let seconds = String(format: "%02i", Int(time) % 60)
        if hours != "00" && hours == "01"{
            return "\(hours) hr \(minutes)m \(seconds)s"
        } else if hours != "00" && hours != "01"{
            return "\(hours) hrs \(minutes)m \(seconds)s"
        } else if hours == "00" {
            return "\(minutes)m \(seconds)s"
        } else {
        return "\(hours):\(minutes):\(seconds)"
        }
    }

   
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
   
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
        //guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        //let managedContext = appDelegate.persistentContainer.viewContext
        
        if editingStyle == .delete {
            
            let sleepEntry = self.fetchedResultsController.object(at: indexPath) as! NSManagedObject
            print(sleepEntry)
            
            managedContext!.delete(sleepEntry)
            do {
                try managedContext!.save()
                //tableView.deleteRows(at: [indexPath], with: .fade)
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        
        switch (type) {
        case .insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .none)
            break
        case .delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .none)
            break
        default:
            break
        }
        
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .none)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .none)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .none)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

 

}
