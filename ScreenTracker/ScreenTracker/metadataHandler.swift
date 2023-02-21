//
//  metadataHandler.swift
//  ScreenTracker
//
//  Created by Donghan Hu on 2/21/23.
//

import Foundation

class metadataHandlerClass {
    
    // read a CSV file
    // return
    func readCSVFile(filePath : String) -> Array<Array<String>>{
        let contentsOfFilePath = Bundle.main.path(forResource: filePath, ofType: "csv") ?? ""
        if (contentsOfFilePath == ""){
            print("the content of this file is empty, the file path is: " + filePath)
        }
        var fileContents = try! String(contentsOfFile: contentsOfFilePath, encoding: .utf8)
        // remove empty rows
        fileContents = cleanRows(file: fileContents)
        let resultArray = csvTransfer(data: fileContents)
        // type: Array<Array<String>>
        // print(type(of: afterTransfer))
        // print(afterTransfer)
        
        return resultArray

    }
    
    // clean rows, replace \r and \n\n with a new line
    func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        return cleanFile
    }
    
    // transfer a string to a string array
    func csvTransfer(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            // print(row)
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }
        return result
    }
    
    func getMetadataForFrontMostApplication (appName: String) -> [String]{
        let csvContent = readCSVFile(filePath: "applescript")
        let csvContentRow = csvContent.count
        
        var resultArray = [String]()
        // [0] : application name
        // [1] : application category
        // [2] : metadata 1
        // [3] : metadata 2
        let csvContentCol = csvContent[0].count
        for i in 0..<csvContentRow{
            let eachRowInArray = csvContent[i] as Array<String>
            let savedApplicationName = eachRowInArray[0] as String
            if (savedApplicationName == appName){
                // found this app
                
                var appleScriptForMetaDataOne = eachRowInArray[1] as String
                var appleScriptForMetaDataTwo = eachRowInArray[2] as String
                
                appleScriptForMetaDataOne = getExecutableAppleScriptByReplacingName(originalString: appleScriptForMetaDataOne, applicationName: appName)
                appleScriptForMetaDataTwo = getExecutableAppleScriptByReplacingName(originalString: appleScriptForMetaDataTwo, applicationName: appName)
                
                // print("appscript one:", appleScriptForMetaDataOne)
                // print("appscript two:", appleScriptForMetaDataTwo)
                
                let applicationMetadataResultOne = runApplescript(applescript: appleScriptForMetaDataOne)
                let applicationMetadataResultTwo = runApplescript(applescript: appleScriptForMetaDataTwo)
                
                let firstResult = runApplescript(applescript:applicationMetadataResultOne)
                let secondResult = runApplescript(applescript:applicationMetadataResultTwo)
                // print("result one:", runApplescript(applescript:applicationMetadataResultOne))
                // print("result two:", runApplescript(applescript:applicationMetadataResultTwo))
                // run twice for formatting problem
                
                resultArray.append(firstResult)
                resultArray.append(secondResult)
                return resultArray
                
            }
            
        }
        return resultArray
        
        
    }
    
    //
    func getExecutableAppleScriptByReplacingName(originalString: String, applicationName : String) -> String{
        let tempString = originalString
        let executabltAppleScript = tempString.replacingOccurrences(of: "AlternativeApplicationName", with: applicationName)
        return executabltAppleScript
    }
    
    // run applescript
    func runApplescript(applescript : String) -> String{
        let tempStr = String(applescript)

        let validString = tempStr.replacingOccurrences(of: "\\n", with: "\n")
        var error: NSDictionary?
        
        let scriptObject = NSAppleScript(source: validString)
        let output: NSAppleEventDescriptor = scriptObject!.executeAndReturnError(&error)
        
        if (error != nil) {
            print("error: \(String(describing: error))")
        }
        if output.stringValue == nil{
            let empty = "the result is empty"
            return empty
        }
        else {
            return (output.stringValue?.description)!
        }
    }
    
    
    
}
