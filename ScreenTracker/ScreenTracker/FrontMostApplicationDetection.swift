//
//  FrontMostApplicationDetection.swift
//  ScreenTracker
//
//  Created by Donghan Hu on 1/24/23.
//

import Foundation
import AppKit

class frontMostAppsClass{
    
    func getFrontMostApplication() -> String{
        let CurrentFrontMostAppName = NSWorkspace.shared.frontmostApplication?.localizedName
        print(CurrentFrontMostAppName)
        return CurrentFrontMostAppName ?? "Null String"
    }
    
}
