//
//  actionHandler.swift
//  ScreenTracker
//
//  Created by Donghan Hu on 2/7/23.
//

import Foundation

class actionHandler{
    
    static let sharedactionHandler = actionHandler()
    
    private init(){
        // init method()
    }
    
    func act1(){
        var inforLogHandler = InforLog()
        let timeStamp = returnTimeStamp() + "   " + "6" + "\n"
        inforLogHandler.writeResponse(timeStamp)
        print("this is action1")
        
    }
    func act2(){
        var inforLogHandler = InforLog()
        let timeStamp = returnTimeStamp() + "   " + "5" + "\n"
        inforLogHandler.writeResponse(timeStamp)
        print("this is action2")
    }
    func act3(){
        var inforLogHandler = InforLog()
        let timeStamp = returnTimeStamp() + "   " + "4" + "\n"
        inforLogHandler.writeResponse(timeStamp)
        print("this is action3")
    }
    
    func act4(){
        var inforLogHandler = InforLog()
        let timeStamp = returnTimeStamp() + "   " + "3" + "\n"
        inforLogHandler.writeResponse(timeStamp)
        print("this is action4")
    }
    
    func act5(){
        var inforLogHandler = InforLog()
        let timeStamp = returnTimeStamp() + "   " + "2" + "\n"
        inforLogHandler.writeResponse(timeStamp)
        print("this is action5")
    }
    
    func act6(){
        var inforLogHandler = InforLog()
        let timeStamp = returnTimeStamp() + "   " + "1" + "\n"
        inforLogHandler.writeResponse(timeStamp)
        print("this is action6")
    }
    
    func defaultFunc() {
        var inforLogHandler = InforLog()
        let timeStamp = returnTimeStamp() + "   " + "0" + "\n"
        inforLogHandler.writeResponse(timeStamp)
        print("no response for notification!")
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
    
}
