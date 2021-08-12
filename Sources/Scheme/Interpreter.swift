//
//  Scheme.swift
//  Scheme
//
//  Created by Niklas Schildhauer on 02.04.21.
//

import Foundation

public protocol Interpreting {
    func interpret(input: String) -> Void
}

public class Interpreter: Interpreting {
    private lazy var reader: SchemeReading = Reader(symbolTable: self.symbolTable)
    private let globalEnvironment: SchemeEnvironment
    private let symbolTable: SymbolTable = SymbolTable()
    private let evaluator: Evaluating
    
    public init(output delegate: PrinterDelegate){
        printer.delegate = delegate
        printer.print(message:"Grüß Gott bei meinem Schemle")

        printer.print(message: "Scheme is starting...")
            
        self.globalEnvironment = Environment(symbolTable: symbolTable)
        self.evaluator = TrampolineEvaluator()
        self.evaluator.initializeBuiltInFunctions(in: self.globalEnvironment)
        self.evaluator.initializeBuiltInSyntax(in: self.globalEnvironment)
        
        _ = Selftest(reader: reader, symbolTable: symbolTable, environment: globalEnvironment, evaluator: self.evaluator)
        
        let path = Bundle.module.path(forResource: "init", ofType: "scm")
        if let path = path {
            self.interpret(input: "(load \"\(path)\")")
        }
        
        printer.print(message: "...done")

    }
    
    public func interpret(input: String) {
        printer.print(message: input)
        let object = reader.read(input: input)
        switch object {
        case .Error:
            printer.print(object: object)
        default:
            let result = evaluator.eval(expression: object, environment: self.globalEnvironment)
            switch result {
            case .Void: break
            case .File(value: var file):
                printer.print(object: result)
                while(!file.endOfFile) {
                    guard let line = file.nextLine() else { continue }
                    self.interpret(input: line)
                }
            default: printer.print(object: result)
            }
        }
    }
}
