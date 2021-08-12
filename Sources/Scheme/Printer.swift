//
//  File.swift
//  
//
//  Created by Niklas Schildhauer on 30.07.21.
//

import Foundation

/// This delegate needs to be implemented by the object which is using this Scheme Interpreter.
/// In this way any output device (console or UI) can be used.
public protocol PrinterDelegate {
    func didComputeOutputString(output: String, style: OutputStyle, in printer: PrinterMarkerProtocol)
}

/// Marker protocol so that the delegate is only used by the printer
public protocol PrinterMarkerProtocol { }

/// This Enum defines the output style of the message.
/// Through this the output device can decide over the style of the ouput.
public enum OutputStyle {
    case error
    case warn
    case standard
    case message
}

//  MARK: Singelton
/// This singelton is used in the whole programm to print something to the console.
let printer = Printer()

//  MARK: Printer implementation
/// Defines all functions which a printer should implement.
protocol SchemePrinting {
    func display(object: Object)
    func print(object: Object)
    func printTag(of object: Object)
    func print(message: String)
    func print(error message: String)
}

/// Implementation of the Printing protocol
class Printer {
    var delegate: PrinterDelegate? = nil
    
    init() { }
}

// MARK: Protocol Conformance
extension Printer: SchemePrinting, PrinterMarkerProtocol {
    /// Prints the object.
    func print(object: Object) {
        self.delegate?.didComputeOutputString(output: self.string(of: object), style: .standard, in: self)
    }
    
    /// Displays the object.
    /// The difference between display and print is that a char or character are printed without: "".
    func display(object: Object) {
        switch object {
        case .String(value: let value):
            self.delegate?.didComputeOutputString(output: value.characters, style: .standard, in: self)
        case .Char(value: let value):
            self.delegate?.didComputeOutputString(output: "\(value.character)", style: .standard, in: self)
        default: self.delegate?.didComputeOutputString(output: self.string(of: object), style: .standard, in: self)
        }
    }
    
    /// Prints a info message for the user. For example informations of the current interpreter state.
    func print(message: String) {
        self.delegate?.didComputeOutputString(output: message, style: .message, in: self)
    }
    
    /// Prints error messages
    func print(error message: String) {
        self.delegate?.didComputeOutputString(output: message, style: .error, in: self)
    }
    
    /// Prints the tag of the object
    func printTag(of object: Object) {
        self.delegate?.didComputeOutputString(output: self.tag(of: object), style: .standard, in: self)
    }
}


//  MARK: Helper functions
private extension Printer {
    
    /// Returns the tag of the object as a String.
    private func tag(of object: Object) -> String {
        switch object {
        case .Integer(_):
            return "INTEGER"
        case .Double(_):
            return "DOUBLE"
        case .String(_):
            return "STRING"
        case .Char(_):
            return "CHAR"
        case .Cons(_):
            return "CONS"
        case .Symbol(_):
            return "SYMBOL"
        case .False:
            return "FALSE"
        case .True:
            return "TRUE"
        case .Null:
            return "NULL"
        case .Void:
            return "VOID"
        case .Environment(_):
            return "ENVIRONMENT"
        case .Syntax(_):
            return "BUILTINSYNTAX"
        case .BuiltInFunction(_):
            return "BUILTINFUNCTION"
        case .UserDefinedFunction(_):
            return "USERDEFINEDFUNCTION"
        case .Error:
            return "ERROR"
        case .FatalError:
            return "FATAL ERROR"
        case .TrampolineFunction(_):
            return "BUILTINTRAMPOLINEFUNCTION"
        case .File(_):
            return "FILEINPUT"
        }
    }
    
    /// Returns a readable string of the value of the object.
    private func string(of object: Object) -> String {
        switch object {
        case .Integer(value: let value):
            return "\(value)"
        case .Double(value: let value):
            return"\(value)"
        case .String(value: let value):
            return "\"\(value.characters)\""
        case .Char(value: let value):
            return"\'\(value.character)\'"
        case .Cons(value: let value):
            return self.consToString(cons: value)
        case .Symbol(value: let value):
            return "\(value.characters)"
        case .False:
            return "#f"
        case .True:
            return "#t"
        case .Null:
            return "()"
        case .Void:
            return "#void"
        case .Environment(value: let value):
            if value.parentEnvironment == nil {
                return "<<top environment>>"
            } else {
                return "<<environment>>"
            }
        case .Syntax(value: let value):
            return "<syntax typ=\(value.type.name)>"
        case .BuiltInFunction(value: let function):
            return "<builtin [code=\(String(describing: function.code))]>"
        case .UserDefinedFunction(value: let value):
            return "(lambda \(self.consToString(cons: value.argList)) \(self.consToString(cons: value.bodyList)))"
            
        /// Creates an input error message and calls the delegate to display the error message
        /// It returns a new line
        case .Error(let message, let line, let function, let file):
            self.delegate?.didComputeOutputString(output: createErrorMessage(message: message, line: line, function: function, file: file, error: "Input Error"), style: .error, in: self)
            return "\n"
            
        /// Creates an fatal error message and calls the delegate to display the error message
        /// It returns a new line
        case .FatalError(message: let message, line: let line, function: let function, file: let file):
            self.delegate?.didComputeOutputString(output: createErrorMessage(message: message, line: line, function: function, file: file, error: "Fatal System Error"), style: .error, in: self)
            return "\n"
        case .TrampolineFunction(value: let function):
            return "<builtin trampoline function [code=\(String(describing: function.code))]>"
        case .File(value: let value):
            return "Read input from file: \(value.path))"
        }
    }
        
    /// Creates a readable error message with emoji.
    private func createErrorMessage(message: String, line: Int, function: String, file: String, error name: String) -> String {
        let fileName = file.split(separator: "/").last
        return """
            
            ❌  \(name.uppercased())
            ❌  ---------------------------
            ❌  Occured in Line \(line) at function: func \(function)
            ❌  in file: \(String(describing: fileName ?? ""))
            ❌  v v v v v v v v v v v v v v
            ❌  \(message)
            ❌  ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^
            """
    
    }
    
    /// Creates a readable version of a given cons. It calls itself recursively.
    private func consToString(cons: SchemeCons, string: String = "") -> String {
        let retVal: String
        if string == "" {
            retVal = "\(self.string(of: cons.car))"
        } else {
            retVal = "\(string) \(self.string(of: cons.car))"
        }
        
        if cons.cdr == .Null {
            return "(\(retVal))"
        }
        guard let cdrCons = cons.cdr.consObject() else {
            return "(\(retVal) . \(self.string(of: cons.cdr)))"
        }
        // the cdr is no cons and not null -> Insert "."
        return self.consToString(cons: cdrCons, string: retVal)
    }
}
