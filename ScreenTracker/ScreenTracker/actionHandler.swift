//
//  actionHandler.swift
//  ScreenTracker
//
//  Created by Donghan Hu on 2/7/23.
//

import Foundation

class actionHandler{
    
    static let sharedactionHandler = actionHandler()
    
    private init(){}
    
    func act1(){
        print("this is action1")
        
    }
    func act2(){
        print("this is action2")
    }
    func act3(){
        print("this is action3")
    }
    
}
