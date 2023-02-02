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
        // create file and file name is: log.txt
        let log = documentDirectoryPath.appendingPathComponent("log.txt")

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
