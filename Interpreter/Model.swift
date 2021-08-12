//
//  Model.swift
//  Scheme
//
//  Created by Niklas Schildhauer on 02.04.21.
//

import Foundation

/// The main model of this Scheme Interpreter
/// It's of enum type. In Swift, enum cases can be associated with a value.
/// For this Scheme Interpreter, an enum case was therefore assigned to all Scheme types and assigned with the appropriate value.
indirect enum Object {
    case Integer (value: Int)
    case Double (value: Double)
    case String (value: SchemeString)
    case Char(value: SchemeChar)
    case Cons (value: SchemeCons)
    case Symbol(value: SchemeSymbol)
    case False // Constant without a value
    case True // Constant without a value
    case Null // Constant without a value
    case Void // Constant without a value
    case Environment(value: SchemeEnvironment)
    case Syntax(value: SchemeSyntax)
    case BuiltInFunction(value: SchemeFunction)
    case TrampolineFunction(value: SchemeTrampolineFunction)
    case UserDefinedFunction(value: SchemeUserDefinedFunction)
    /// Errors are used when the user makes an incorrect entry.
    case Error(message: String, line: Int = #line, function: String = #function, file: String = #file)
    /// Fatal error are used to identify bugs in code.
    case FatalError(message: String, line: Int = #line, function: String = #function, file: String = #file)
    case File(value: SchemeFile)
}


// MARK: Scheme Type implementations

/// Scheme Symbol implementation. Type class instead of struct to allow call by reference possible.
class SchemeSymbol: Hashable {
    let characters: String
    let length: Int
    init(value: String) {
        self.characters = value
        self.length = value.count
    }
    
    public static func == (lhs: SchemeSymbol, rhs: SchemeSymbol) -> Bool {
        lhs.characters == rhs.characters && lhs.length == rhs.length
    }
    
    /// Hash function to create a hash of the givin string.
    /// Used by the symboltable.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(characters.hash)
    }
}

/// Scheme Cons implementation. Type class instead of struct to allow call by reference possible.
class SchemeCons: Equatable {
    var car: Object
    var cdr: Object
    
    init(car: Object, cdr: Object) {
        self.car = car
        self.cdr = cdr
    }
    
    public static func == (lhs: SchemeCons, rhs: SchemeCons) -> Bool {
        return lhs.cdr == rhs.cdr && lhs.car == rhs.car
    }
}

/// Scheme String implementation. Type class instead of struct to allow call by reference possible.
class SchemeString {
    var characters: String {
        didSet {
            self.length = self.characters.count
        }
    }
    var length: Int
    
    init(value: String) {
        self.characters = value
        self.length = value.count
    }
}

/// Scheme Char implementation as struct.
struct SchemeChar {
    var character: Character
    var intValue: Int
    
    init(character: Character) {
        self.character = character
        self.intValue = character.hexDigitValue ?? -1
    }
}

/// Scheme Function (or Builtin Function) implementation. Stores the built in Function code.
struct SchemeFunction {
    let code: (Int, Stack<Object>) -> Object
}

struct SchemeTrampolineFunction {
    let code: (SchemeCons, SchemeEnvironment) -> Void
}

/// Scheme User defined functionimplementation. Stores the parent environment
/// and the arg and body list.
struct SchemeUserDefinedFunction {
    let homeEnvironment: SchemeEnvironment
    let argList: SchemeCons
    let bodyList: SchemeCons
}

/// Scheme Syntax implementation. Story the type of the syntax.
struct SchemeSyntax {
    let type: SyntaxType
}

/// Scheme Syntax Type implementation. Used by the SchemeSyntax Object
/// and is used by the evaluator to switch over the Scheme Syntax.
enum SyntaxType: String {
    case Define
    case Begin
    case If
    case Set = "set!"
    case Lambada
    case Quote
}

/// SyntaxType extension for the printer to print the name of the type.
extension SyntaxType {
    var name: String {
        return self.rawValue.lowercased()
    }
}

/// Scheme File implementation. Stores the data of the input file.
struct SchemeFile {
    let path: String
    var data: [String]
    var endOfFile: Bool {
        return data.count == 0
    }
    
    /// Converts the data input string to an array of each line
    init(path: String, data: String) {
        self.path = path
        self.data = data.split(separator: "\n").map({ Substring in
            String(Substring)
        })
    }
        
    /// returns the valuable string line or nil if EOF is reached.
    mutating func nextLine() -> String? {
        var nextLine: String = ""
                
        while(!nextLine.isInputValuable()) {
            if endOfFile {
                break
            }
            let lineValue = String(data.removeFirst()).skipWhiteSpace()
            if lineValue.first != ";" {
                if nextLine == "" {
                    nextLine = lineValue
                } else {
                    nextLine.append(" \(lineValue)")
                }
            }
        }
        return nextLine != "" ? nextLine : nil
    }
}


// MARK: Object extensions

/// This extension of Object makes the enum compliant to the Equatable protocol.
/// Through this the two checks for equality (=) & (eq?) are implemented.
extension Object: Equatable {
    // This function checks for equal values -> (=)
    public static func == (lhs: Object, rhs: Object) -> Bool {
        switch (lhs, rhs) {
        case (let .Double(d1), let .Double(d2)):
            return d1 == d2
        case (let .Integer(i1), let .Integer(i2)):
            return i1 == i2
        case (let .String(s1), let .String(s2)):
            return s1.characters == s2.characters
        case (let .Char(c1), let .Char(c2)):
            return c1.character == c2.character
        case (let .Cons(c1), let .Cons(c2)):
            return c1.cdr == c2.cdr && c2.car == c1.car
        case (let .Symbol(s1), let .Symbol(s2)):
            return s1 === s2
        case (.False, .False):
            return true
        case (.True, .True):
            return true
        case (.Void, .Void):
            return true
        case (.Null, .Null):
            return true
        case (let .UserDefinedFunction(u1), let .UserDefinedFunction(u2)):
            return u1.argList == u2.argList && u1.bodyList == u2.bodyList
        default:
            return false
        }
    }
    
    // This function checks for equility of the objects -> (eq?)
    public static func === (lhs: Object, rhs: Object) -> Bool {
        switch (lhs, rhs) {
        case (let .String(s1), let .String(s2)):
            return s1 === s2
        case (let .Cons(c1), let .Cons(c2)):
            return c1 === c2
        case (let .Symbol(s1), let .Symbol(s2)):
            return s1 === s2
        default:
            return lhs == rhs
        }
    }
}

/// This extension of Object helps to avoid the use of many switches in the code.
/// Instead, these functions can be called and used to check if the object is of a certain type.
/// It returns either nil or the requested object.
extension Object {
    func intValue() -> Int? {
        switch self {
        case .Integer(let value): return value
        default: return nil
        }
    }
    
    func doubleValue() -> Double? {
        switch self {
        case .Double(value: let value): return value
        default: return nil
        }
    }
    
    func stringObject() -> SchemeString? {
        switch self {
        case .String(value: let value): return value
        default: return nil
        }
    }
    
    func symbolObject() -> SchemeSymbol? {
        switch self {
        case .Symbol(value: let value): return value
        default: return nil
        }
    }
    
    func charObject() -> SchemeChar? {
        switch self {
        case .Char(value: let value): return value
        default: return nil
        }
    }
    
    func consObject() -> SchemeCons? {
        switch self {
        case .Cons(value: let value): return value
        default: return nil
        }
    }
    
    func userFunctionObject() -> SchemeUserDefinedFunction? {
        switch self {
        case .UserDefinedFunction(value: let value): return value
        default: return nil
        }
    }
    
    func environmentObject() -> SchemeEnvironment? {
        switch self {
        case .Environment(value: let value): return value
        default: return nil
        }
    }
    
    func syntaxObject() -> SchemeSyntax? {
        switch self {
        case .Syntax(value: let value): return value
        default: return nil
        }
    }
    
    func trampolineFunctionObject() -> SchemeTrampolineFunction? {
        switch self {
        case .TrampolineFunction(value: let value): return value
        default: return nil
        }
    }
    
    func builtinFunctionObject() -> SchemeFunction? {
        switch self {
        case .BuiltInFunction(value: let value): return value
        default: return nil
        }
    }
}
