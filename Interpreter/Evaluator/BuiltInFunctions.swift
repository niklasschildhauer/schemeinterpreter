//
//  File.swift
//  
//
//  Created by Niklas Schildhauer on 02.08.21.
//

import Foundation

//  MARK: Implementation of the Builtin functions
//  MARK: Layer 4 - Eval Builtin functions
/// In this file all built in functions are defined. All functions have the same structure. They take as first argument
/// the first index of the functions arguments and the eval stack Object which is of kind Stack<Object>.
/// All return a Scheme Object which also can be an Error.+

/// Plus function
//  (+ num ...)  -> number
func plus(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count == 0 {
        return .Error(message: "(+) - Enter at least one value")
    }
    var sum = 0
    for integer in args {
        guard let value = integer.intValue() else {
            return .Error(message: "(+) - Only integers are valid")
        }
        sum = sum + value
    }
    return .Integer(value: sum)
}

/// Minus function
//  (- num ...)  -> number
func minus(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    var args = evalStack.getObjects(from: firstArgIndex)
    if !(args.count > 1) {
        return .Error(message: "(-) - Enter at least one value")

    }
    guard let firstInt = args.removeFirst().intValue() else {
        return .Error(message: "(-) - Only integers are valid")
    }
    
    if args.count == 0 {
        return .Integer(value: -firstInt)
    }

    var retVal = firstInt
    for object in args {
        guard let int = object.intValue() else {
            return .Error(message: "(-) - Only integers are valid")
        }
        retVal = retVal - int
    }
    return .Integer(value: retVal)
}

/// Times function
//  (* num ...)  -> number
func times(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    var product = 1
    for integer in args {
        guard let value = integer.intValue() else {
            return .Error(message: "(*) - Only integers are valid")

        }// Throw an error}
        product = product * value
    }
    return .Integer(value: product)
}

/// Remainder function
//  (% num1 num2)  -> number
func remainder(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object  {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count != 2 {
        return .Error(message: "(%) - Needs exactly two arguments")

    }
    guard let firstInt = args.first?.intValue() else {
        return .Error(message: "(/) - Only integers are valid")
    }
    guard let secondInt = args.last?.intValue() else {
        return .Error(message: "(/) - Only integers are valid")
    }
    
    return .Integer(value: firstInt % secondInt)
}

/// Qoutient function
//  (/ num1 ...)  -> double
func quotient(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    var args = evalStack.getObjects(from: firstArgIndex)
    if !(args.count > 1) {
        return .Error(message: "(/) - Enter at least one value")

    }
    guard let firstInt = args.removeFirst().intValue() else {
        return .Error(message: "(/) - Only integers are valid")
    }
    
    if args.count == 0 {
        return .Double(value: 1.0 / Double(firstInt))
    }

    var retVal:Double = Double(firstInt)
    for object in args {
        guard let int = object.intValue() else {
            return .Error(message: "(/) - Only integers are valid")
        }
        retVal = retVal / Double(int)
    }
    return .Double(value: retVal)
}

/// Truncate function
//  (truncate double)  -> number
func truncate(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count != 1 {
        return .Error(message: "(truncate) - Needs exactly one argument")
    }
    
    if args.first?.doubleValue() != nil {
        let value = args.first!.doubleValue()!
        return .Integer(value: Int(value))
    }
    
    guard let value = args.first?.intValue() else {
        return .Error(message: "(truncate) - Needs a number value")
    }

    return .Integer(value: value)
}

/// Equal function. Checks for identity
//  (eq? object object)  -> bool
func eq(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count != 2 {
        return .Error(message: "(eq?) - Needs exactly two arguments")

    }
    return args[0] === args[1] ? .True : .False
}

/// Equal number function
//  (= num1 num2)  -> bool
func eqnr(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count != 2 {
        return .Error(message: "(=) - Needs exactly two arguments")

    }
    guard let firstInt = args[0].intValue(),
          let secondInt = args[1].intValue() else {
        return .Error(message: "(=) - Only integers are valid")

    }
    return firstInt == secondInt ? .True : .False
}

/// greater then function
// (> num1 num2)  -> bool
func gtnr(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count != 2 {
        return .Error(message: "(>) - Needs exactly two arguments")

    }
    guard let firstInt = args[0].intValue(),
          let secondInt = args[1].intValue() else {
        return .Error(message: "(>) - Only integers are valid")
    }
    return firstInt > secondInt ? .True : .False
}

/// smaller then function
// (< num1 num2)  -> bool
func stnr(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count != 2 {
        return .Error(message: "(<) - Needs exactly two arguments")

    }
    guard let firstInt = args[0].intValue(),
          let secondInt = args[1].intValue() else {
        return .Error(message: "(<) - Only integers are valid")

    }
    return firstInt < secondInt ? .True : .False
}

/// cons function
//  (cons object object) -> SchemeCons
func cons(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count != 2 {
        return .Error(message: "(cons) - Needs exactly two arguments")
    }
    
    return .Cons(value: .init(car: args[0], cdr: args[1]))
}

/// car function
//  (car SchemeCons) -> Object
func car(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count != 1 {
        return .Error(message: "(car) - Needs exactly two arguments")
    }
    guard let cons = args[0].consObject() else {
        return .Error(message: "(car) - Argument is not a cons")
    }
    
    return cons.car
}

/// cdr function
//  (cdr SchemeCons) -> Object
func cdr(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count != 1 {
        return .Error(message: "(cdr) - Needs exactly two arguments")
    }
    guard let cons = args[0].consObject() else {
        return .Error(message: "(cdr) - Argument is not a cons")
    }
    
    return cons.cdr
}

/// display function. Displays the Object to the console
//  (display Object) -> Void
func display(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    
    if args.count == 0 {
        return .Error(message: "(display) - Needs at least one argument")
    }
    
    args.forEach { (object) in
        printer.display(object: object)
    }
    return .Void
}

/// print function. Prints the Object to the console
//  (print Object) -> Void
func print(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    
    if args.count == 0 {
        return .Error(message: "(print) - Needs at least one argument")
    }
    
    args.forEach { (object) in
        printer.print(object: object)
    }
    return .Void
}

/// load function. Loads a file from the given url
//  (load String(Url)) -> File
func load(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count != 1 {
        return .Error(message: "(load) - Needs exactly one argument")
    }
    
    if args.first?.doubleValue() != nil {
        let value = args.first!.doubleValue()!
        return .Integer(value: Int(value))
    }
    
    guard let path = args.first?.stringObject()?.characters else {
        return .Error(message: "(load) - Needs a string path")
    }
    
    do {
        let fileContent = try String(contentsOfFile: path)
        return .File(value: .init(path: path, data: fileContent))
    } catch {
        return .Error(message: "(load) - the given path is not valid")
    }
}




/// ----------------
/// String functions
/// ----------------

/// String length function
//  (string-length SchemeString) -> number
func stringLength(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count != 1 {
        return .Error(message: "(string-length) - Needs exactly one argument")
    }
    guard let string = args.first?.stringObject() else {
        return .Error(message: "(string-length) - Needs a string as argument")
    }

    return .Integer(value: string.length)
}

/// String ref function
//  (string-ref string index) -> character
func stringRef(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count != 2 {
        return .Error(message: "(string-ref) - Needs exactly two argument")
    }
    guard let string = args.first?.stringObject() else {
        return .Error(message: "(string-ref) - Needs a string as first argument")
    }
    guard let index = args.last?.intValue()  else {
        return .Error(message: "(string-ref) - Needs a string as second argument")
    }
    
    if index >= string.length {
        return .Error(message: "(string-ref) - Index out of bounds")
    }
    let char = Character(string.characters[index])
    return .Char(value: .init(character: char))
}


/// String append function
// (string-append string1 ... stringN) -> string
func stringAppend(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count < 1 {
        return .Error(message: "(string-append) - Needs min one argument")
    }
    
    var retVal: String = ""
    
    for string in args {
        guard let value = string.stringObject()?.characters else {
            return .Error(message: "(string-append) - Only string as arguments are valid")
        }
        retVal.append(value)
    }
    
    return .String(value: .init(value: retVal))
}

/// String equal function
// (string-equal string1 string2) -> Bool
func stringEqual(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count != 2 {
        return .Error(message: "(string=?) - Needs exactly two argument")
    }
    guard let firstString = args.first?.stringObject()?.characters else {
        return .Error(message: "(string=?) - Needs a string as first argument")
    }
    guard let secondString = args.last?.stringObject()?.characters  else {
        return .Error(message: "(string=?) - Needs a string as second argument")
    }
    
    if firstString == secondString {
        return .True
    }
    return .False
}


/// ------------------
/// Question functions
/// ------------------

/// Is it a string?
// (string? string1) -> Bool
func stringQuestion(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count != 1 {
        return .Error(message: "(string?) - Needs exactly one argument")
    }
    if  args.first?.stringObject() != nil {
        return .True
    }

    return .False
}

/// Is it a bool?
// (bool? Bool) -> Bool
func boolQuestion(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count != 1 {
        return .Error(message: "(bool?) - Needs exactly one argument")
    }
    if  args.first == .True || args.first == .False {
        return .True
    }

    return .False
}

/// Is it a number
// (number? number) -> Bool
func numberQuestion(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count != 1 {
        return .Error(message: "(number?) - Needs exactly one argument")
    }
    if  (args.first?.intValue() != nil) || ((args.first?.doubleValue()) != nil) {
        return .True
    }

    return .False
}

/// Is it a cons?
// (cons? cons) -> Bool
func consQuestion(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count != 1 {
        return .Error(message: "(cons?) - Needs exactly one argument")
    }
    if  args.first?.consObject() != nil {
        return .True
    }

    return .False
}

/// Is it a built in function?
// (builtin-function? function) -> Bool
func builtinFunctionQuestion(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count != 1 {
        return .Error(message: "(builtin-function?) - Needs exactly one argument")
    }
    if  args.first?.builtinFunctionObject() != nil {
        return .True
    }

    return .False
}

/// Is it a user function?
// (user-function? function) -> Bool
func userFunctionQuestion(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count != 1 {
        return .Error(message: "(user-function?) - Needs exactly one argument")
    }
    if  args.first?.userFunctionObject() != nil {
        return .True
    }

    return .False
}

/// Is it a function?. Could be built in or user defined
// (function? function) -> Bool
func functionQuestion(firstArgIndex: Int, in evalStack: Stack<Object>) -> Object {
    let args = evalStack.getObjects(from: firstArgIndex)
    if args.count != 1 {
        return .Error(message: "(user-function?) - Needs exactly one argument")
    }
    if (args.first?.userFunctionObject() != nil) ||  (args.first?.builtinFunctionObject() != nil) {
        return .True
    }

    return .False
}

