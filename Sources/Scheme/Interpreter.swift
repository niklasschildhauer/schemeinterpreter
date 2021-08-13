//
//  Interpreter.swift
//  Scheme
//
//  Created by Niklas Schildhauer on 02.08.21.
//

import Foundation

//  MARK: Implementation Reader
/// Defines the only function which is visible outside of the library.
public protocol SchemeInterpreterProtocol {
    func interpret(input: String) -> Void
}

/// This class is the herat of the interpreter and coordinates the interaction of the reader,
/// printer and evaluator. It also creates all objects which are needed for the interpreter.
public class Interpreter {
    private let reader: SchemeReaderProtocol
    private let globalEnvironment: SchemeEnvironment
    private let symbolTable: SchemeSymbolTableProtocol = SymbolTable()
    private let evaluator: SchemeEvaluatorProtocol = TrampolineEvaluator()
    
    public init(output delegate: PrinterDelegate){
        printer.delegate = delegate
        
        // Is displayed at begin
        let welcomeMessage = """
            Grüß Gott und herzlich Willkommen bei meinem Scheme Interpreter 🙋🏼‍♂️!
            
                 ƛƛƛ  ƛƛ
                  ƛƛƛ
                ƛƛ ƛƛƛ
                    ƛƛƛ
                     ƛƛƛ
                    ƛƛƛƛƛ
                  ƛƛƛ  ƛƛƛ
                 ƛƛƛ    ƛƛƛ
               ƛƛƛ       ƛƛƛ
             ƛƛƛ          ƛƛƛ
            ƛƛƛ            ƛƛƛ
            
            made with ❤︎ and in Swift
            
            """
        printer.print(message: welcomeMessage)
        printer.print(message: "----------------------------")
        printer.print(message: "Scheme is starting...\n")
        
        self.globalEnvironment = Environment(symbolTable: self.symbolTable)
        self.evaluator.initializeBuiltInFunctions(in: self.globalEnvironment)
        self.evaluator.initializeBuiltInSyntax(in: self.globalEnvironment)
        self.reader = Reader(symbolTable: self.symbolTable)
        
        self.startSelftest()
        self.loadInitFile()
            
        printer.print(message: "\n...done")
        printer.print(message: "----------------------------\n\n")
    }
}

// MARK: Protocol Conformance
extension Interpreter: SchemeInterpreterProtocol {
    //  MARK: Important
    /// The only public function outside the library. To use this interpreter,
    /// this function must be called and the PrinterDelegate returns the output
    public func interpret(input: String) {
        // convert the input string to a SchemeInput
        let object = reader.read(input: input)
        
        switch object {
        case .Error, .FatalError:
            // return an error message if the input is not valid
            printer.print(hint: "Typed: \(input)\n")
            printer.print(object: object)
        default:
            // evaluate the scheme object
            let result = evaluator.eval(expression: object, environment: self.globalEnvironment)
            
            switch result {
            // Print nothing if the functions result is void.
            case .Void: break
            // If it's a file, the readFile function is called.
            case .File(value: let file): self.readFile(file: file)
            // Otherwise the printer is called to print the object.
            default: printer.print(object: result)
            }
        }
    }
}

private extension Interpreter {
    /// Starts the selftest and generates all objects for it
    private func startSelftest() {
        let testSymbolTable = SymbolTable()
        let testReader = Reader(symbolTable: testSymbolTable)
        let testEnvironment = Environment(symbolTable: testSymbolTable)
        self.evaluator.initializeBuiltInSyntax(in: testEnvironment)
        self.evaluator.initializeBuiltInFunctions(in: testEnvironment)
        _ = Selftest(reader: testReader,
                     symbolTable: testSymbolTable,
                     environment: testEnvironment,
                     evaluator: self.evaluator)
    }

    /// This function iterates over each input line of a scheme file.
    /// For each line the interpret function is called to interpret it.
    private func readFile(file: SchemeFile) {
        var file = file
        var count = 1
        printer.print(message: "\(file.path)")
        while(!file.endOfFile) {
            guard let line = file.nextLine() else { continue }
            printer.print(hint: "\(count): \(line)")
            self.interpret(input: line)
            count = count + 1
        }
    }
    
    /// Loads the init file to intialize a few basic functions and insert them into the
    /// global environment.
    private func loadInitFile() {
        // Load
        let path = Bundle.module.path(forResource: "init", ofType: "scm")
        if let path = path {
            self.interpret(input: "(load \"\(path)\")")
        }
    }
}
