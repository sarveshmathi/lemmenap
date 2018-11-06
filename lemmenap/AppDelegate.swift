//
//  AppDelegate.swift
//  lemmenap
//
//  Created by Sarvesh on 11/10/18.
//  Copyright © 2018 Sarvesh. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       print("did finish launching with options")
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            print("granted: \(granted)")
            UserDefaults.standard.set(granted, forKey: "notificationsEnabled")
        }
        //http://www.thomashanning.com/push-notifications-local-notifications-tutorial/#Local_notifications
        
        if !isKeyPresentInUserDefaults() {
            UserDefaults.standard.setValue(3, forKey: "alarmRepeat")
            UserDefaults.standard.setValue(0.75, forKey: "alarmVolume")
        }
        
        print("Alarm Volume: \(UserDefaults.standard.float(forKey: "alarmVolume"))")
        print("Alarm Repeat: \(UserDefaults.standard.integer(forKey: "alarmRepeat"))")
        print("Reminder 1 \(UserDefaults.standard.object(forKey: "ReminderOne") ?? 0)")
        print("Reminder 2 \(UserDefaults.standard.object(forKey: "ReminderTwo") ?? 0)")
        print("Reminder 3 \(UserDefaults.standard.object(forKey: "ReminderThree") ?? 0)")
        print("Reminder 4 \(UserDefaults.standard.object(forKey: "ReminderFour") ?? 0)")
        
        print("Documents Directory: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not Found!")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        print("Application will resign active")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("Application did enter background")
        appQuitNotification()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("Application will enter foreground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("Application did become active")
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("Application will terminate")
        
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "lemmenap")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: - Set up notification
    func appQuitNotification(){
            if HomeViewController.timerRunning == true {
                print("timer running, notifcation sent")
                let content = UNMutableNotificationContent()
                content.title = "Nap Timer Has Stopped"
                content.body = "Restart timer and leave app running in foreground"
                content.sound = UNNotificationSound.default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
                
                let request = UNNotificationRequest(identifier: "AppQuit", content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            } else {
                print("timer not running, notification not sent")
            }
    }
    
    func isKeyPresentInUserDefaults() -> Bool {
        return UserDefaults.standard.object(forKey: "alarmRepeat") != nil
    }


}



