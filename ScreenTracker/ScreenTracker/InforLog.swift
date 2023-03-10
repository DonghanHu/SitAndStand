//
//  InforLog.swift
//  ScreenTracker
//
//  Created by Donghan Hu on 2/2/23.
//

import Foundation

struct InforLog: TextOutputStream {

    /// Appends the given string to the stream.
    ///
    // mutating: can change a property inside a method
    mutating func write(_ string: String) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
        let documentDirectoryPath = paths.first!
        // create file and file name is: log.csv
        // with date Name
        let currentDate = dateHandlerClass().logFileWithDate()
        let fileName = currentDate + "-Log" + ".csv"
        // let log = documentDirectoryPath.appendingPathComponent("log.csv")
        let folderPath = documentDirectoryPath.appendingPathComponent("LoggingData")
        let log = folderPath.appendingPathComponent(fileName)
        
        // print("this is log file path: " + log.absoluteString)

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
    
    // for logging responses
    mutating func writeResponse(_ string: String) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
        let documentDirectoryPath = paths.first!
        let currentDate = dateHandlerClass().logFileWithDate()
        // .csv file
        let fileName = currentDate + "-LogRe" + ".csv"
        let folderPath = documentDirectoryPath.appendingPathComponent("LoggingData")
        let log = folderPath.appendingPathComponent(fileName)
        
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
    

}
