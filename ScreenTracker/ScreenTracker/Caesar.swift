//
//  Caesar.swift
//  ScreenTracker
//
//  Created by Donghan Hu on 4/4/23.
//

import Foundation

class Caesar {
    

    
    
    func encrypt(message: String, shift: Int) -> String {

        func shiftLetter(ucs: UnicodeScalar) -> UnicodeScalar {
            let firstLetter = Int(UnicodeScalar("A").value) // 65, 97
            let lastLetter = Int(UnicodeScalar("Z").value)  // 90, 122
            let letterCount = lastLetter - firstLetter + 1  // 26 letters
            
            let f1 = Int(UnicodeScalar("a").value)
            let l2 = Int(UnicodeScalar("z").value)
            

            let value = Int(ucs.value)
            switch value {
            case firstLetter...lastLetter:
                // Offset relative to first letter:
                var offset = value - firstLetter
                // Apply shift amount (can be positive or negative):
                offset += shift
                // Transform back to the range firstLetter...lastLetter:
                offset = (offset % letterCount + letterCount) % letterCount
                // Return corresponding character:
                return UnicodeScalar(firstLetter + offset)!
            case f1...l2:
                var offset = value - f1
                offset += shift
                offset = (offset % letterCount + letterCount) % letterCount
                return UnicodeScalar(f1 + offset)!
            default:
                // Not in the range A...Z, leave unchanged:
                return ucs
            }
        }
        let msg = message
        // let msg = message.uppercased()
        return String(String.UnicodeScalarView(msg.unicodeScalars.map(shiftLetter)))
    }
    
    
}
