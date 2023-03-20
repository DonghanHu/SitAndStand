//
//  notifications.swift
//  ScreenTracker
//
//  Created by Donghan Hu on 1/25/23.
//

import Foundation
import AppKit


class alertDialogClass{
    
    func confirmIsReady(question: String, text: String){
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "OK")
        // alert.addButton(withTitle: "Cancel")
        
        // run modal to display this alert dialog
        alert.runModal()
        
        // return alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
    }
    
}
