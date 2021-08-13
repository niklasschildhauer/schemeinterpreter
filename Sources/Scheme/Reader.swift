//
//  Reader.swift
//  Scheme
//
//  Created by Niklas Schildhauer on 03.08.21.
//

import Foundation

//  MARK: Implementation Reader
/// Defines all functions which a reader should implement.
protocol SchemeReaderProtocol {
    func read(input: String) -> Object
}

/// This class is used to read the input stirng and create a Scheme Object from it
/// or throw an input error.
class Reader {
    private let symbolTable: SchemeSymbolTableProtocol
    
    //  MARK: Constructor
    init(symbolTable: SchemeSymbolTableProtocol) {
        self.symbolTable = symbolTable
    }
}

//  MARK: Protocol conformance
extension Reader: SchemeReaderProtocol {

    /// Creates a new input buffer for each new statement.
    /// It is called by the Interpreter and returns the read Object.
    func read(input: String) -> Object {
        let inputBuffer = InputBuffer(input: input)
        
        if !inputBuffer.isValuable {
            return .Error(message: "The input \"\(input)\" is not a Scheme statement.")
        }
        return self.read(buffer: inputBuffer)
    }
}

//  MARK: Implementation
private extension Reader  {
    /// Takes a input buffer and evaluates its statement into a known Scheme Object of
    /// the type Object and returns it.
    private func read(buffer: InputBuffer) -> Object {
        guard let element = buffer.nextElement else {
            // No element to interpret left -> Return Object.Null
            return .Null
        }
        buffer.removeNextElement()
       
        // The following determines which element it is and then create a Object from it.
        // Checks if the element is a number and converts it to a int
        if element.isNumber(),
           let int = Int(element) {
            return.Integer(value: int)
        }
        
        // Checks if the element is a float and converts it to a double
        if element.isDouble(),
           let double = Double(element) {
            return.Double(value: double)
        }
        
        // Checks if the element is #t.
        if element.isTrue() {
            return .True
        }
        
        // Checks if the element is #f.
        if element.isFalse() {
            return .False
        }
        
        // Checks if the element starts with '( -> quote
        if element == "'" {
            if buffer.nextElement == "(" {
                buffer.removeNextElement()
                let args = self.read(list: buffer)
                let quote = Object.Syntax(value: .init(type: .Quote))
                return .Cons(value: .init(car: quote, cdr: .Cons(value: .init(car: args, cdr: .Null))))
            }
            return .Syntax(value: .init(type: .Quote))
        }
        
        // Checks if the element is a string
        if element.isString(),
           element.count > 1,
           element.first == "\"" && element.last == "\"" {
            var retVal = element
            retVal.removeFirst()
            retVal.removeLast()
            return Object.String(value: .init(value: retVal))
        }
        
        // Checks if the element is a cons.

        // Special case: It could also be a function or a list.
        // But first we want it to be of type Object.Cons
        // Calls the helper function read(list buffer: InputBuffer)
        if element == "(" {
            return read(list: buffer)
        }
        
        // Since nothing else applies it must be a symbol
        let symbol = symbolTable.getOrCreate(symbol: element)
        return .Symbol(value: symbol)
    }

    /// This function creates one cons element.
    /// It is a recursive function: The cdr calls this function again and therefore it could concat to a list of cons
    /// Iit terminates with a Object.Null cdr.
    private func read(list buffer: InputBuffer) -> Object {
        guard let next = buffer.nextElement else { return .Null }
        var car: Object = .Null
        var cdr: Object = .Null
    
        // The cons ends and thus the cdr must be Object.Null
        if next == ")" {
            buffer.removeNextElement()
            return .Null
        }
        
        car = self.read(buffer: buffer)
        cdr = self.read(list: buffer)
        
        return .Cons(value: .init(car: car, cdr: cdr))
    }
}


//  MARK: Implementation Input Buffer
private protocol InputBuffering {
    var isValuable: Bool { get }
    var nextElement: String? { get }
    
    func removeNextElement()
}

/// This class is used to store the read input string and evaluate each element of it.
/// A new input buffer is created for each instruction that is to be evaluated.
private class InputBuffer {
    private var input: String?
    private var elements: [String] = []
    
    //  MARK: Constructor
    /// A new input buffer is created with a input string.
    /// This string is then broken down into its components
    init(input: String) {
        // danach solange lesen bis ' ', '\n', '\t', '(', ')'
        self.input = input.skipWhiteSpaceAtBothEnds()
        if self.isValuable {
            self.elements = self.divideInputInElements(input: input)
        }
    }
}

//  MARK: Protocol conformance
extension InputBuffer: InputBuffering {
    
    /// Returns true if the statement is valuable
    var isValuable: Bool {
        get {
            guard let input = input else { return false }
            if !input.isValuable() {
                return false
            }
            // check for EOF
            guard input.first != nil else {
                // The read input is empty
                return false
            }
            return true
        }
    }
    
    /// Returns the next element.
    var nextElement: String? {
        get {
            self.elements.first
        }
    }
    
    /// Removes the next element from the buffer
    func removeNextElement() {
        self.elements.removeFirst()
    }
}


//  MARK: Helper functions
private extension InputBuffer {
    
    /// This helper function splits the input string into its components.
    private func divideInputInElements(input: String) -> [String] {
        var element = ""
        var elements: [String] = []
        
        // Iterates over each char in the string
        input.forEach { char in
            switch char {
            case "(", ")":
                if element != "" {
                    elements.append(element)
                    element = ""
                }
                elements.append("\(char)")
            case " ":
                if element != "" {
                    elements.append(element)
                    element = ""
                }
            default:
                element.append(char)
            }
        }
        
        if element != "" {
            elements.append(element)
        }
        return elements
    }
}
