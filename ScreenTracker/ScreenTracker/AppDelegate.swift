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
import CryptoSwift

struct frontMostApplicationInformation {
    static var frontMostApplication = "empty"
    static var frontMostApplicationFirstMetadata    = "Empty"
    static var frontMostApplciationSecondMetadata   = "Empty"
    
    static var emptyMedata                          = "Default Empty Metadata"

}

struct notificationSetting {
    static var notificationEnabled                  = false
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    
    private var statusItem  : NSStatusItem!
    
    private var firstButton : NSMenuItem!
    
    private var detectingFrontMostAppTimer = Timer()
    
    private var repeatedNotifcationTimer = Timer()
    
    // time interval to detect front most application
    private var timeIntervalForDetecing = 5.0
    
    private var timeIntervaleForNotification = 1800.0
    
    private var encryptionShiftindex = 3
    private var decryptionShiftindex = 23
    
    private let key = "2tC2H19lkVbQDfakxcrtNMQdd0FloLyw"
    private let iv = "bbC2H19lkVbQDfak"
    
    // user notification
    let un = UNUserNotificationCenter.current()
    
    // initate log file for saving information
    var inforLogHandler = InforLog()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let Caesarhandler = Caesar()
        
        let otp: String = "attAck on Titan / , . % 123 play"
        let encryptedOtp: String = try! otp.aesEncrypt(key: key, iv: iv)
        print(encryptedOtp)
        let decryptedOtp : String = try! encryptedOtp.aesDecrypt(key: key, iv: iv)
        print(decryptedOtp)
        
        // 2
        // statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        // 3
        if let button = statusItem.button {
            button.image = NSImage(named: "icons8-table-30")
            // button.image = NSImage(named: NSImage.quickLookTemplateName)
        }
        
        // create default folder for saving logging data
        // Documents/LoggingData
        createLogFolder()
        
        // create respond file
        createRespondFile()
        
        // set up status menu
        setupMenus()
        
        // initiate front-most application name
        setInitialFrontMostApplication()
        
        // get metadata for the initial frontmost application
        // let dataLog = returnTimeStamp() + "    " + frontMostApplicationInformation.frontMostApplication + "\n"
        var dataLog = returnTimeStamp() + ", " + commaCheck(str: frontMostApplicationInformation.frontMostApplication) + "\n"
        let encryptedDataLog: String = try! dataLog.aesEncrypt(key: key, iv: iv)
        inforLogHandler.write(encryptedDataLog)
        inforLogHandler.write("\n")
        
        let metadataHandlerObj = metadataHandlerClass()
        let resultArray = metadataHandlerObj.getMetadataForFrontMostApplication( appName: frontMostApplicationInformation.frontMostApplication ?? "invalid app name!")
        // let metadata = frontMostApplicationInformation.frontMostApplicationFirstMetadata + "    " + frontMostApplicationInformation.frontMostApplciationSecondMetadata + "\n"
        var metadata = commaCheck(str: frontMostApplicationInformation.frontMostApplicationFirstMetadata) + ", " + commaCheck(str: frontMostApplicationInformation.frontMostApplciationSecondMetadata) + "\n"
        let encryptedmetadata: String = try! metadata.aesEncrypt(key: key, iv: iv)
        inforLogHandler.write(encryptedmetadata)
        inforLogHandler.write("\n")
        
        // set notification center's delegate
        UNUserNotificationCenter.current().delegate = self
        
        // request for permission to send notification
        un.requestAuthorization(options: [.alert, .sound]) { (authorized, error) in
            if authorized {
                notificationSetting.notificationEnabled = true
                print("Authorized")
            } else if !authorized {
                notificationSetting.notificationEnabled = false
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
               print(notification)
               print(notification.identifier)
//               if notification.identifier == "identifierCancel" {
//                  identifiers.append(notification.identifier)
//               }
           }
            
           // UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
        
    }
    
    // set up the status menu with buttons
    func setupMenus() {
        // 1
        let menu = NSMenu()
        
        // 2
        firstButton = NSMenuItem(title: "Start", action: #selector(trackerAction), keyEquivalent: "1")
        menu.addItem(firstButton)
        
         
//        let secondButton = NSMenuItem(title: "Noti", action: #selector(alertWindow), keyEquivalent: "2")
//        menu.addItem(secondButton)

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        // 3
        statusItem.menu = menu
    }
    
    // merge button 1 and button 2
    @objc func trackerAction() {
        
        // check if notification is enabled or not
        if notificationSetting.notificationEnabled == false {
            alertWindow()
        } else {
            // start recording
            if (firstButton.title == "Start"){
                // change button title
                statusItem.button?.image = NSImage(named: "icons8-record-48")
                firstButton.title = "Stop"
                // start to monitor front-most application
                self.detectingFrontMostAppTimer = Timer.scheduledTimer(timeInterval: timeIntervalForDetecing, target: self, selector: #selector(printFrontMostApplication), userInfo: nil, repeats: true)
                
                // set notification for every 30 minutes
                self.repeatedNotifcationTimer = Timer.scheduledTimer(timeInterval: timeIntervaleForNotification, target: self, selector: #selector(notificationFunction), userInfo: nil, repeats: true)
                print("notification timer status: ", self.repeatedNotifcationTimer.isValid)
            } else{
                firstButton.title = "Start"
                // stop two timers
                statusItem.button?.image = NSImage(named: "icons8-table-30")
                detectingFrontMostAppTimer.invalidate()
                repeatedNotifcationTimer.invalidate()
                print("notification timer status: ", self.repeatedNotifcationTimer.isValid)
            }
        }

        
    }
    
    // set periodically notification function
    
    // https://stackoverflow.com/questions/69782010/is-it-possible-to-set-default-alert-style-for-macos-unnotification
    // notificaiton styles
    @objc func notificationFunction() {
        print("this is notification function")
        self.un.removeAllDeliveredNotifications()
        self.un.removeAllPendingNotificationRequests()
        
        un.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                let content = UNMutableNotificationContent()
                
                content.title = "Sit/stand desk survey"
                // content.body = "How willing are you  to use the stand mode at this moment?                                       ."
                content.body = "How willing are you  to use the stand mode at this moment?"
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
                
                // add actions for buttons
                let action1 = UNNotificationAction(identifier: "action1", title: "Definitely (6)", options: [])
                let action2 = UNNotificationAction(identifier: "action2", title: "Very Probably (5)", options: [])
                let action3 = UNNotificationAction(identifier: "action3", title: "Probably (4)", options: [])
                let action4 = UNNotificationAction(identifier: "action4", title: "Possibly (3)", options: [])
                let action5 = UNNotificationAction(identifier: "action5", title: "Probably Not (2)", options: [])
                let action6 = UNNotificationAction(identifier: "action6", title: "Definitely Not (1)", options: [])

                
                let category = UNNotificationCategory(identifier: "actions", actions: [action1, action2, action3, action4, action5, action6], intentIdentifiers: [], options: [])
                
                // time interval should be at least 60 if repeated
                // set 30 minutes
                // let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
                // 1800 is set in the timer, not here
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                
                self.un.setNotificationCategories([category])
                
                self.un.add(request) { (error) in
                    if error != nil {
                        print(error?.localizedDescription as Any)
                    }
                }
                // end of self.un.add()
            }
            // end of if in settnigs
        }
        // end of un.getNotificationSettings

    }
    
    // firstButton action method
    @objc func recordingFunction() {
        
        if (firstButton.title == "Start"){
            // change button title
            statusItem.button?.image = NSImage(named: "icons8-record-48")
            firstButton.title = "Stop"
            // start to monitor front-most application
            self.detectingFrontMostAppTimer = Timer.scheduledTimer(timeInterval: timeIntervalForDetecing, target: self, selector: #selector(printFrontMostApplication), userInfo: nil, repeats: true)
            
        } else{
            firstButton.title = "Start"
            statusItem.button?.image = NSImage(named: "icons8-table-30")
            detectingFrontMostAppTimer.invalidate()
        }
    }
    
    @objc func alertWindow(){
        let x = errorReadingResults(question: "Notificaiton is not enabled.", text: "Please allow to send notification in System Preferences and restart this app. Thank you!")
    }
    
    // test notification related function
    @objc func testFunction(){
        
        // firstly, remove previous set notificaiton
        // might be helpful
        self.un.removeAllDeliveredNotifications()
        self.un.removeAllPendingNotificationRequests()
        
        print("pending notification: ")
        print(UNUserNotificationCenter.getPendingNotificationRequests(self.un))
        
        // secondly, create and start new notification for today
        print("this is notification method in testFunction")
        
        // un.removeAllDeliveredNotifications()
        
        un.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                let content = UNMutableNotificationContent()
                
                content.title = "Sit/stand desk survey"
                // content.subtitle = "this is subtitle"
                content.body = "How willing are you  to use the stand mode at this moment?"
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
                
                let action1 = UNNotificationAction(identifier: "action1", title: "Definitely Not", options: [])
                let action2 = UNNotificationAction(identifier: "action2", title: "Probably Not", options: [])
                let action3 = UNNotificationAction(identifier: "action3", title: "Possibly", options: [])
                let action4 = UNNotificationAction(identifier: "action4", title: "Probably", options: [])
                let action5 = UNNotificationAction(identifier: "action5", title: "Very Probably", options: [])
                let action6 = UNNotificationAction(identifier: "action6", title: "Definitely", options: [])

                
                let category = UNNotificationCategory(identifier: "actions", actions: [action1, action2, action3, action4, action5, action6], intentIdentifiers: [], options: [])
                
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
        // print("initial front most application is: " + tempName!)
        
        
        // initialize metadata for the front most application when ScreenTracker is lanunhed
        let metadataHandlerObj = metadataHandlerClass()
        let resultArray = metadataHandlerObj.getMetadataForFrontMostApplication( appName: tempName ?? "invalid app name!")
//        print("in initialized setting, result Array: \n")
//        print(resultArray)
        //  resultArray should has two elements inside
        if(resultArray.count != 2){
            // erros
            frontMostApplicationInformation.frontMostApplicationFirstMetadata = "Default Empty Metadata"
            frontMostApplicationInformation.frontMostApplciationSecondMetadata = "Default Empty Metadata"
            
        } else{
            frontMostApplicationInformation.frontMostApplicationFirstMetadata = resultArray[0]
            frontMostApplicationInformation.frontMostApplciationSecondMetadata = resultArray[1]
        }
        
    }
    
    @objc func printFrontMostApplication() {
        
        let Caesarhandler = Caesar()
        
        var CurrentFrontMostAppName = NSWorkspace.shared.frontmostApplication?.localizedName?.description
        // handle 'nil' siutation
        if(CurrentFrontMostAppName == nil){
            CurrentFrontMostAppName = "error for current front most applciation"
        }
        // print(CurrentFrontMostAppName!)
        
        // if it is desktop, then front most application would be "Finder"
        
        // if frontmost applicatin name is different from pre-set one
        // metadata has changed
        // reset front most application name
        if(frontMostApplicationInformation.frontMostApplication != CurrentFrontMostAppName){
            frontMostApplicationInformation.frontMostApplication = CurrentFrontMostAppName!
            // save new front most application
            // let dataLog = returnTimeStamp() + "    " + frontMostApplicationInformation.frontMostApplication + "\n"
            // separate by comma
            let dataLog = returnTimeStamp() + ", " + commaCheck(str: frontMostApplicationInformation.frontMostApplication) + "\n"
            let encrypteddataLog: String = try! dataLog.aesEncrypt(key: key, iv: iv)
            inforLogHandler.write(encrypteddataLog)
            inforLogHandler.write("\n")
            
            // get metadata for the frontmost application
            let metadataHandlerObj = metadataHandlerClass()
            let resultArray = metadataHandlerObj.getMetadataForFrontMostApplication( appName: CurrentFrontMostAppName ?? "invalid app name!")
            print("result Array: \n")
            print(resultArray)
            if (resultArray.count == 2){
                // let metadata = resultArray[0] + "    " + resultArray[1] + "\n"
                var metadata = commaCheck(str: resultArray[0]) + ", " + commaCheck(str: resultArray[1]) + "\n"
                // metadata = Caesarhandler.encrypt(message: metadata, shift: encryptionShiftindex)
                let encryptedmetadata: String = try! metadata.aesEncrypt(key: key, iv: iv)
                inforLogHandler.write(encryptedmetadata)
                inforLogHandler.write("\n")
            } else {
                // let metadata = frontMostApplicationInformation.frontMostApplicationFirstMetadata + "    " + frontMostApplicationInformation.frontMostApplciationSecondMetadata
                var metadata = frontMostApplicationInformation.emptyMedata + ", " + frontMostApplicationInformation.emptyMedata + "\n"
                // metadata = Caesarhandler.encrypt(message: metadata, shift: encryptionShiftindex)
                let encryptedmetadata: String = try! metadata.aesEncrypt(key: key, iv: iv)
                inforLogHandler.write(encryptedmetadata)
                inforLogHandler.write("\n")
            }
            
            
        }
        // else the front most application is not changed
        // check if metadata changed
        // do noting, save the current metadata again
        else{
            // timestamp + app name
            var dataLog = returnTimeStamp() + ", " + commaCheck(str: frontMostApplicationInformation.frontMostApplication) + "\n"
            // dataLog = Caesarhandler.encrypt(message: dataLog, shift: encryptionShiftindex)
            let encrypteddataLog: String = try! dataLog.aesEncrypt(key: key, iv: iv)
            inforLogHandler.write(encrypteddataLog)
            inforLogHandler.write("\n")
            
            // get metadata for the frontmost application
            let metadataHandlerObj = metadataHandlerClass()
            let resultArray = metadataHandlerObj.getMetadataForFrontMostApplication( appName: CurrentFrontMostAppName ?? "invalid app name!")
            if (resultArray.count == 2){
                var metadata = commaCheck(str: resultArray[0]) + ", " + commaCheck(str: resultArray[1]) + "\n"
                // metadata = Caesarhandler.encrypt(message: metadata, shift: encryptionShiftindex)
                let encryptedmetadata: String = try! metadata.aesEncrypt(key: key, iv: iv)
                inforLogHandler.write(encryptedmetadata)
                inforLogHandler.write("\n")
            } else {
                // result array has wrong length, write default empty values
                var metadata = frontMostApplicationInformation.emptyMedata + ", " + frontMostApplicationInformation.emptyMedata + "\n"
                // metadata = Caesarhandler.encrypt(message: metadata, shift: encryptionShiftindex)
                let encryptedmetadata: String = try! metadata.aesEncrypt(key: key, iv: iv)
                inforLogHandler.write(encryptedmetadata)
                inforLogHandler.write("\n")
            }
            
            
            
        }
        // end of else block
        
        
        // return CurrentFrontMostAppName ?? "Null String"
    }
    
    // function to check whether a string contains ","
    func commaCheck(str: String) -> String{
        let tartgetStr = "COMMA"
        let newString = str.replacingOccurrences(of: ",", with: "COMA", options: .literal, range: nil)
        return newString
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
    
    // create file to save responses only
    func createRespondFile(){
        let paths = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
        let documentDirectoryPath = paths.first!
        let currentDate = dateHandlerClass().logFileWithDate()
        // .csv file
        let fileName = currentDate + "-LogRe" + ".csv"
        let folderPath = documentDirectoryPath.appendingPathComponent("LoggingData")
        let log = folderPath.appendingPathComponent(fileName)
        let logString = log.absoluteString
        print(logString)
        let string = ""
        do {
            let handle = try FileHandle(forWritingTo: log)
            handle.seekToEndOfFile()
            handle.write(string.data(using: .utf8)!)
            handle.closeFile()
        } catch {
            print(error.localizedDescription)
            do {
                try string.data(using: .utf8)?.write(to: log)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // function for caesar encryption
    func caesar(value: String, shift: Int) -> String {
        // Empty character array.
        var result = [Character]()
        // Loop over utf8 values.
        for u in value.utf8 {
            // Apply shift to UInt8.
            let s = Int(u) + shift
            // See if value exceeds Z.
            // ... The Z is 26 past "A" which is 97.
            // ... If greater than "Z," shift backwards 26.
            // ... If less than "A," shift forward 26.
            if s > 97 + 25 {
                result.append(Character(UnicodeScalar(s - 26)!))
            } else if s < 97 {
                result.append(Character(UnicodeScalar(s + 26)!))
            } else {
                result.append(Character(UnicodeScalar(s)!))
            }
        }
        // Return String from array.
        return String(result)
    }
    
    
    // function for the alert window
    func errorReadingResults(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.addButton(withTitle: "OK")
        return alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
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
            
            // print(response.notification.request.content.userInfo)
            
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
            case "action4":
                actionHandler.sharedactionHandler.act4()
                break
            case "action5":
                actionHandler.sharedactionHandler.act5()
                break
            case "action6":
                actionHandler.sharedactionHandler.act6()
            default:
                print("this is default option. ")
                let url = URL(string: "https://forms.gle/GTN3752S1fGhLX6B8")!
                if NSWorkspace.shared.open(url) {
                    print("default browser was successfully opened")

                }
                actionHandler.sharedactionHandler.defaultFunc()
                break
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        return completionHandler([.list, .sound])
    }
}

extension String {

    func aesEncrypt(key: String, iv: String) throws -> String {
        let data = self.data(using: .utf8)!
        let encrypted = try! AES(key: key, iv: iv, padding: .pkcs7).encrypt([UInt8](data))
        let encryptedData = Data(encrypted)
        return encryptedData.toHexString()
    }

    func aesDecrypt(key: String, iv: String) throws -> String {
        let data = self.dataFromHexadecimalString()!
        let decrypted = try! AES(key: key, iv: iv, padding:.pkcs7).decrypt([UInt8](data))
        let decryptedData = Data(decrypted)
        return String(bytes: decryptedData.bytes, encoding: .utf8) ?? "Could not decrypt"
    }

    func dataFromHexadecimalString() -> Data? {
        var data = Data(capacity: count / 2)
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, options: [], range: NSMakeRange(0, count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)
            data.append(num!)
        }
            return data
    }

}

extension Data {

    var bytes: Array<UInt8> {
        return Array(self)
    }

    func toHexString() -> String {
        return bytes.toHexString()
    }

}



