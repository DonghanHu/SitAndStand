//
//  AppDelegate.swift
//  ScreenTracker
//
//  Created by Donghan Hu on 1/18/23.
//

import Cocoa
import AppKit
import Foundation

import NotificationCenter
import UserNotifications


struct frontMostApplicationInformation {
    static var frontMostApplication = "empty"
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    
    private var statusItem  : NSStatusItem!
    
    private var firstButton : NSMenuItem!
    
    private var detectingFrontMostAppTimer = Timer()
    
    // time interval to detect front most application
    private var timeIntervalForDetecing = 2.0
    
    // user notification
    let un = UNUserNotificationCenter.current()
    
    // initate log file for saving information
    var inforLogHandler = InforLog()
    // inforLogHandler.write("hello")
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        // 2
        // statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        // 3
        if let button = statusItem.button {
            button.image = NSImage(named: "icons8-desk-24 (1)")
            // button.image = NSImage(named: NSImage.quickLookTemplateName)
        }
        
        // create default folder for saving logging data
        // Documents/LoggingData
        createLogFolder()
        
        // set up status menu
        setupMenus()
        
        // initiate front-most application name
        setInitialFrontMostApplication()
        
        // get metadata for the initial frontmost application
        let dataLog = returnTimeStamp() + "    " + frontMostApplicationInformation.frontMostApplication + "\n"
        inforLogHandler.write(dataLog)
        let metadataHandlerObj = metadataHandlerClass()
        let resultArray = metadataHandlerObj.getMetadataForFrontMostApplication( appName: frontMostApplicationInformation.frontMostApplication ?? "invalid app name!")
        print("result Array: \n")
        print(resultArray)
        let metadata = resultArray[0] + "    " + resultArray[1] + "\n"
        inforLogHandler.write(metadata)
        
        // set notification center's delegate
        UNUserNotificationCenter.current().delegate = self
        
        // request for permission to send notification
        un.requestAuthorization(options: [.alert, .sound]) { (authorized, error) in
            if authorized {
                print("Authorized")
            } else if !authorized {
                print("Not authorized")
            } else {
                print(error?.localizedDescription as Any)
            }
        }
        // https://stackoverflow.com/questions/31951142/how-to-cancel-a-localnotification-with-the-press-of-a-button-in-swift
        //
        
        // check codes here
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
           var identifiers: [String] = []
           for notification:UNNotificationRequest in notificationRequests {
               if notification.identifier == "identifierCancel" {
                  identifiers.append(notification.identifier)
               }
           }
           UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
        
        
        self.un.removeAllDeliveredNotifications()
        self.un.removeAllPendingNotificationRequests()
        self.un.removePendingNotificationRequests(withIdentifiers: ["screentrackerTest"])
        self.un.removeDeliveredNotifications(withIdentifiers: ["screentrackerTest"])
        // self.un.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        
        
    }
    
    // set up the status menu with buttons
    func setupMenus() {
        // 1
        let menu = NSMenu()

        // 2
        firstButton = NSMenuItem(title: "Start", action: #selector(recordingFunction), keyEquivalent: "1")
        menu.addItem(firstButton)
        
        // test button for notifiaction
        let secondButton = NSMenuItem(title: "Noti", action: #selector(testFunction), keyEquivalent: "2")
        menu.addItem(secondButton)

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        // 3
        statusItem.menu = menu
    }
    
    // firstButton action method
    @objc func recordingFunction() {
        
        if (firstButton.title == "Start"){
            // change button title
            firstButton.title = "Stop"
            // start to monitor front-most application
            self.detectingFrontMostAppTimer = Timer.scheduledTimer(timeInterval: timeIntervalForDetecing, target: self, selector: #selector(printFrontMostApplication), userInfo: nil, repeats: true)
            
        } else{
            firstButton.title = "Start"
            detectingFrontMostAppTimer.invalidate()
        }
    }
    
    // test notification related function
    @objc func testFunction(){
        
        // firstly, remove previous set notificaiton
        // might be helpful
        self.un.removeAllDeliveredNotifications()
        self.un.removeAllPendingNotificationRequests()
        
        
        // secondly, create and start new notification for today
        print("this is notification method in testFunction")
        
//        let notification = NSUserNotification()
//        notification.title = "this is title"
//        notification.subtitle = "this is subtitle"
//        notification.informativeText = "this is informative text"
//        notification.contentImage = NSImage(named: NSImage.Name("notificationIcon"))
//
//        NSUserNotificationCenter.default.deliver(notification)
        
        // un.removeAllDeliveredNotifications()
        
        un.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                let content = UNMutableNotificationContent()
                
                content.title = "this is title"
                content.subtitle = "this is subtitle"
                content.body = "this is body"
                content.sound = UNNotificationSound.default
                content.categoryIdentifier = "actions"
                
                let id = "screentrackerTest"
                
                let filePath = Bundle.main.path(forResource: "notificationIcon", ofType: ".png")
                let fileUrl = URL(fileURLWithPath: filePath!)
                do {
                    let attachment = try UNNotificationAttachment.init(identifier: "AnotherTest", url: fileUrl, options: .none)
                    content.attachments = [attachment]
                    
                } catch let error {
                    print(error.localizedDescription as Any)
                }
                
                // weekdays: 1 is Sunday
                let weekdays = [2, 3, 4, 5, 6]
                
                for day in weekdays {
                    
                }
                
                let action1 = UNNotificationAction(identifier: "action1", title: "Ac1", options: [])
                let action2 = UNNotificationAction(identifier: "action2", title: "Ac2", options: [])
                let action3 = UNNotificationAction(identifier: "action3", title: "Ac3", options: [])
                
                let category = UNNotificationCategory(identifier: "actions", actions: [action1, action2, action3], intentIdentifiers: [], options: [])
                
                // time interval should be at least 60 if repeated
                // set 30 minutes
                // let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                
                self.un.setNotificationCategories([category])
                
                self.un.add(request) { (error) in
                    if error != nil {
                        print(error?.localizedDescription as Any)
                    }
                }
                
                
            }
            
        }
    }
    
    // get timestamps
    func returnTimeStamp() -> String{
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let dateString = formatter.string(from: now)
        return dateString
    }
    
    // set initial front most application name as default value
    func setInitialFrontMostApplication() {
        var tempName = NSWorkspace.shared.frontmostApplication?.localizedName
        // handle 'nil' situation
        if(tempName == nil){
            tempName = "empty"
        }
        frontMostApplicationInformation.frontMostApplication = tempName!
        print("initial front most application is: " + tempName!)
    }
    
    @objc func printFrontMostApplication() {
        var CurrentFrontMostAppName = NSWorkspace.shared.frontmostApplication?.localizedName?.description
        // handle 'nil' siutation
        if(CurrentFrontMostAppName == nil){
            CurrentFrontMostAppName = "error for current front most applciation"
        }
        // print(CurrentFrontMostAppName!)
        
        // if it is desktop, then front most application would be "Finder"
        
        // reset front most application name
        if(frontMostApplicationInformation.frontMostApplication != CurrentFrontMostAppName){
            frontMostApplicationInformation.frontMostApplication = CurrentFrontMostAppName!
            // save new front most application
            let dataLog = returnTimeStamp() + "    " + frontMostApplicationInformation.frontMostApplication + "\n"
            inforLogHandler.write(dataLog)
            
            // get metadata for the frontmost application
            let metadataHandlerObj = metadataHandlerClass()
            let resultArray = metadataHandlerObj.getMetadataForFrontMostApplication( appName: CurrentFrontMostAppName ?? "invalid app name!")
            print("result Array: \n")
            print(resultArray)
            let metadata = resultArray[0] + "    " + resultArray[1] + "\n"
            inforLogHandler.write(metadata)
            
        }
        // else the front most application is not changed
        else{
            
            
        }
//        print(CurrentFrontMostAppName!)
//        print("timestamp is: ", returnTimeStamp())
        
        
        // return CurrentFrontMostAppName ?? "Null String"
    }
    
    // function create default folder for saving logging data under document directory
    func createLogFolder(){
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let dataPath = docURL.appendingPathComponent("LoggingData")
        print("folder path is: " + dataPath.absoluteString)
        if !FileManager.default.fileExists(atPath: dataPath.path) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        } else{
            print("logging data folder is exist!")
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "ScreenTracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
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
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }

}


extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.content.categoryIdentifier == "actions" {
            switch response.actionIdentifier{
            case "action1":
                actionHandler.sharedactionHandler.act1()
                break
            case "action2":
                actionHandler.sharedactionHandler.act2()
                break
            case "action3":
                actionHandler.sharedactionHandler.act3()
                break
            default:
                break
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        return completionHandler([.list, .sound])
    }
}



