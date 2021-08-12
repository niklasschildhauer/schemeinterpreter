//
//  Extension.swift
//  Scheme
//
//  Created by Niklas Schildhauer on 03.04.21.
//

import Foundation

/// This Extension of the type String is used to help the Reader to interpret the input string.
extension String {
    /// Checks if the input is a string
    func isString() -> Bool {
        let regex = try! NSRegularExpression(pattern: "(^\".*\"$)")
        let range = NSRange(location: 0, length: self.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }

    /// Checks if the is a Symbol
    func isSymbol() -> Bool {
        let regex = try! NSRegularExpression(pattern: "[A-Za-z]")
        let range = NSRange(location: 0, length: self.count)
        return regex.matches(in: self, options: [], range: range).first != nil
    }

    /// Checks if the input is Number
    func isNumber() -> Bool {
        let regex = try! NSRegularExpression(pattern: "(^\\-?[0-9]+$)")
        let range = NSRange(location: 0, length: self.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
    
    /// Checks if the input is true
    func isTrue() -> Bool {
        return self == "#t"
    }
    
    /// Checks if the input is false
    func isFalse() -> Bool {
        return self == "#f"
    }

    /// Checks if the input is a Float
    func isDouble() -> Bool {
        let regex = try! NSRegularExpression(pattern: "(^\\-?[0-9]*\\.[0-9]+$)")
        let range = NSRange(location: 0, length: self.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
    
    /// Checks if the input is a valid cons (can contain multiple cons).
    /// This function counts the opening and closing brackets to detect if the input is valid.
    func isValuable() -> Bool {
        var openCount = 0;
        var closeCount = 0;
        // count number of opening and closing parantheseses
        for char in self {
            if char == "(" {
                openCount = openCount + 1;
            }
            if char == ")" {
                closeCount = closeCount + 1;
            }
            if closeCount > openCount {
                return false
            }
        }
        return openCount == closeCount
    }
}

//  MARK: Helper functions
/// This extension of String contains helper function to mutate a string value.
extension String {
    
    /// Removes from the string the whitespaces in the front
    func skipWhiteSpace() -> String {
        var returnValue = self
        while(isWhiteSpace(char: returnValue.first)) {
            returnValue.removeFirst()
        }
        return returnValue
    }
    
    /// Helper function
    private func isWhiteSpace(char: Character?) -> Bool {
        guard let char = char else { return false }
        return char == " "
            || char == "\t"
            || char == "\n"
            || char == "\r"
    }
    
    /// Returns true if the string is a valuable statement
    func isInputValuable() -> Bool {
        var openCount = 0;
        var closeCount = 0;
        // count number of opening and closing parantheseses
        if self == "" {
            return false
        }
        
        self.forEach { char in
            if char == "(" {
                openCount = openCount + 1;
            }
            if char == ")" {
                closeCount = closeCount + 1 ;
            }
            if closeCount > openCount {
                ERROR(message: "not a valid cons")
            }
        }
        return openCount == closeCount
    }
    
    /// Removes from the string the whitespaces in the front and back.
    func skipWhiteSpaceAtBothEnds() -> String {
        var returnValue = self.skipWhiteSpace()
        while(isWhiteSpace(char: returnValue.last)) {
            returnValue.removeLast()
        }
        return returnValue
    }
}

/// This Extension of the type String is used to get a specific char at a specific index.
/// The code is used from: https://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language
extension String {
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, count) ..< count]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)),
                                            upper: min(count, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
