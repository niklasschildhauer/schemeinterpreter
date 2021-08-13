//
//  Selftest.swift
//  Scheme
//
//  Created by Niklas Schildhauer on 23.07.21.
//

import Foundation

func ASSERT(condition: Bool, message: String) {
    if !condition {
        printer.print(error: "❌  \(message)")
    }
}

/// This class is a test class. It is called at the start of the programm to test its functionality.
class Selftest {
    // Change this value to disable the tests!
    private let testEnable = true
    private let reader: SchemeReaderProtocol
    private let symbolTable: SymbolTable
    private let environment: SchemeEnvironment
    private let evaluator: SchemeEvaluatorProtocol
    
    init(reader: SchemeReaderProtocol,
         symbolTable: SymbolTable,
         environment: SchemeEnvironment,
         evaluator: SchemeEvaluatorProtocol) {
        self.reader = reader
        self.symbolTable = symbolTable
        self.environment = environment
        self.evaluator = evaluator
        
        if testEnable {
            runTests()
        }
    }
    
    private func runTests() {
        printer.print(message: "Start selftest...")

        runModelTests()
        runSymbolTest()
        runReaderTest()
        runEnvironmentTest()
        runEvaluatorTest()
        
        printer.print(message: "...selftest done")
    }
    
    private func runModelTests() {
        let int1 = Object.Integer(value: 123)
        ASSERT(condition: int1.intValue() == 123, message: "Integer value")
        ASSERT(condition: int1.intValue() != 13, message: "Integer value")
        
        let double1 = Object.Double(value: 123.123)
        ASSERT(condition: double1.doubleValue() == 123.123, message: "Double value")
        ASSERT(condition: double1.doubleValue() != 13, message: "Integer value")
        
        let string1 = Object.String(value: .init(value: "Test"))
        ASSERT(condition: string1.stringObject()?.characters == "Test", message: "String object")
        ASSERT(condition: string1.stringObject()?.length == 4, message: "String object")
        
        let cons1 = Object.Cons(value: .init(car: int1, cdr: string1))
        ASSERT(condition: cons1.consObject()?.car == int1, message: "Cons car is int1")
        ASSERT(condition: cons1.consObject()?.cdr == string1, message: "Cons car is string1")
    }
    
    private func runReaderTest() {
        let input1 = "(define a 123)"
        let object = reader.read(input: input1)
        ASSERT(condition: object.consObject()?.car.symbolObject() == self.symbolTable.getOrCreate(symbol: "define") , message: "Reader - cons car")
    }
    
    private func runSymbolTest() {
        let symbol1 = symbolTable.getOrCreate(symbol: "define")
        symbolTable.getOrCreate(symbol: "+")
        symbolTable.getOrCreate(symbol: "-")
        symbolTable.getOrCreate(symbol: "define")
        symbolTable.getOrCreate(symbol: "+")
        symbolTable.getOrCreate(symbol: "-")
        
        ASSERT(condition: symbolTable.size == 3, message: "Symboltable adds not only unkown symbols")
        ASSERT(condition: symbol1 === symbolTable.getOrCreate(symbol: "define"), message: "Symboltable does not return the known symbol")
        
        symbolTable.getOrCreate(symbol: "define1")
        symbolTable.getOrCreate(symbol: "+2")
        symbolTable.getOrCreate(symbol: "-3")
        symbolTable.getOrCreate(symbol: "define4")
        symbolTable.getOrCreate(symbol: "+5")
        symbolTable.getOrCreate(symbol: "-6")
        symbolTable.getOrCreate(symbol: "define7")
        symbolTable.getOrCreate(symbol: "+8")
        symbolTable.getOrCreate(symbol: "-9")
        symbolTable.getOrCreate(symbol: "define10")
        symbolTable.getOrCreate(symbol: "+11")
        symbolTable.getOrCreate(symbol: "-12")
        symbolTable.getOrCreate(symbol: "define14")
        symbolTable.getOrCreate(symbol: "+13")
        symbolTable.getOrCreate(symbol: "-15")
        symbolTable.getOrCreate(symbol: "define16")
        symbolTable.getOrCreate(symbol: "+17")
        symbolTable.getOrCreate(symbol: "-18")
        symbolTable.getOrCreate(symbol: "define19")
        symbolTable.getOrCreate(symbol: "+20")
        symbolTable.getOrCreate(symbol: "-21")
    }
    
    private func runEnvironmentTest() {
        let key = self.symbolTable.getOrCreate(symbol: "abc")
        let value = Object.Double(value: 23.2)
        self.environment.insertOrUpdate(key: key, value: value)
        let returnVal = environment.get(key: key)
        ASSERT(condition: returnVal == value, message: "Environment Error 1")
        
        let key2 = self.symbolTable.getOrCreate(symbol: "tes")
        let value2 = Object.Integer(value: 23)
        self.environment.insertOrUpdate(key: key2, value: value2)
        let returnVal2 = environment.get(key: key2)
        ASSERT(condition: returnVal2 == value2, message: "Environment Error 2")

        
        let key3 = self.symbolTable.getOrCreate(symbol: "def")
        let value3 = Object.Cons(value: .init(car: .Char(value: SchemeChar(character: "C")), cdr: .String(value: .init(value: "Hallo"))))
        self.environment.insertOrUpdate(key: key3, value: value3)
        let returnVal3 = environment.get(key: key3)
        ASSERT(condition: returnVal3 == value3, message: "Environment Error 3")
    }
    
    func runEvaluatorTest() {
        // +
        let plus1 = "(+ 123 123 43 4)"
        let consplus1 = self.reader.read(input: plus1)
        let plusresult = self.evaluator.eval(expression: consplus1, environment: self.environment)
        ASSERT(condition: plusresult == .Integer(value: 293), message: "Simple plus calculation")
        
        let plusdefine1 = "(define integerplus 34)"
        let consplusdefine1 = self.reader.read(input: plusdefine1)
        _ = self.evaluator.eval(expression: consplusdefine1, environment: self.environment)
        let plus2 = "(+ 123 integerplus 43 4)"
        let consplus2 = self.reader.read(input: plus2)
        let plusresult2 = self.evaluator.eval(expression: consplus2, environment: self.environment)
        ASSERT(condition: plusresult2 == .Integer(value: 204), message: "Plus calculation with variable")
        
        // -
        let minus1 = "(- 123 123 43 4)"
        let consminus1 = self.reader.read(input: minus1)
        let minusresult = self.evaluator.eval(expression: consminus1, environment: self.environment)
        ASSERT(condition: minusresult == .Integer(value: -47), message: "Simple minus calculation")
        
        let minus2 = "(- 20 10)"
        let consminus2 = self.reader.read(input: minus2)
        let minusresult2 = self.evaluator.eval(expression: consminus2, environment: self.environment)
        ASSERT(condition: minusresult2 == .Integer(value: 10), message: "Simple minus calculation")
        
        // *
        let multi1 = "(* 123 123 43 4)"
        let consmulti1 = self.reader.read(input: multi1)
        let multi1result = self.evaluator.eval(expression: consmulti1, environment: self.environment)
        ASSERT(condition: multi1result == .Integer(value: 2602188), message: "Simple multiplication calculation")
        
        // cons
        let cons1 = "(cons \"String\" 123)"
        let conscons = self.reader.read(input: cons1)
        let consresult = self.evaluator.eval(expression: conscons, environment: self.environment)
        ASSERT(condition: consresult == .Cons(value: .init(car: .String(value: .init(value: "String")), cdr: .Integer(value: 123))), message: "Simple cons generation")
        
        let definecons = "(define consi (cons \"String\" 123))"
        let consdefine = self.reader.read(input: definecons)
        _ = self.evaluator.eval(expression: consdefine, environment: self.environment)
        
        // car
        let car1 = "(car consi)"
        let carcons1 = self.reader.read(input: car1)
        let carconsresult1 = self.evaluator.eval(expression: carcons1, environment: self.environment)
        ASSERT(condition: carconsresult1 == .String(value: .init(value: "String")), message: "Car of cons object")
    
        let car2 = "(car (cons \"String\" 123))"
        let carcons2 = self.reader.read(input: car2)
        let carconsresult2 = self.evaluator.eval(expression: carcons2, environment: self.environment)
        ASSERT(condition: carconsresult2 == .String(value: .init(value: "String")), message: "Car of cons object")
        
        // cdr
        let cdr1 = "(cdr consi)"
        let cdrcons1 = self.reader.read(input: cdr1)
        let cdrconsresult1 = self.evaluator.eval(expression: cdrcons1, environment: self.environment)
        ASSERT(condition: cdrconsresult1 == .Integer(value: 123), message: "Cdr of cons object")
                
        // define
        let defineCons = self.reader.read(input: "(define (<= a b) (> a b))")
        _ = self.evaluator.eval(expression: defineCons, environment: self.environment)
        let function = self.environment.get(key: self.symbolTable.getOrCreate(symbol: "<="))!
        let bodyList =  SchemeCons(car: .Cons(value: .init(car: .Symbol(value: self.symbolTable.getOrCreate(symbol: ">")), cdr: .Cons(value: .init(car: .Symbol(value: self.symbolTable.getOrCreate(symbol: "a")), cdr: .Cons(value: .init(car: .Symbol(value: self.symbolTable.getOrCreate(symbol: "b")), cdr: .Null)))))), cdr: .Null)
        let expectedFunction = Object.UserDefinedFunction(value: .init(homeEnvironment: self.environment,
                                                                 argList: .init(car: .Symbol(value: self.symbolTable.getOrCreate(symbol: "a")), cdr: .Cons(value: .init(car: .Symbol(value:self.symbolTable.getOrCreate(symbol: "b")), cdr: .Null))),
                                                                 bodyList: bodyList))
                                                        
        ASSERT(condition: function == expectedFunction, message: "Wrong user defined function created.")
        
        // lambda
        let lambdaCons = self.reader.read(input: "(define somefunc (lambda (a b c) (+ (+ a b) c)))")
        _ = self.evaluator.eval(expression: lambdaCons, environment: self.environment)
        let lambdaExecution = self.reader.read(input: "(somefunc 1 2 3)")
        let result = self.evaluator.eval(expression: lambdaExecution, environment: self.environment)
        ASSERT(condition: result == Object.Integer(value: 6), message: "Test User defined Lambda function")
        
        
        
        //fibonacci
        self.callExpression(string: "(define fibonacci (lambda (n) (if (< n 2) 1 (+ (fibonacci (- n 1)) (fibonacci (- n 2))))))")
        let fibonacci10 = self.callExpression(string: "(fibonacci 10)")
        ASSERT(condition: fibonacci10 == .Integer(value: 89), message: "Recursive call fibonacci 10")
        
        self.callExpression(string: "(define factorial (lambda (n) (if (= n 0) 1 (* n (factorial (- n 1))))))")
        let factorial4 = self.callExpression(string: "(factorial 4)")
        ASSERT(condition: factorial4 == .Integer(value: 24), message: "Recursive call factorial 4")

        
        // nested user functions
        self.callExpression(string: "(define functioncall (lambda (a b c) (+ (+ a b) c)))")
        let functioncall6 = self.callExpression(string: "(functioncall 1 2 3)")
        ASSERT(condition: functioncall6 == .Integer(value: 6), message: "Nested function call 1 2 3")
    }
    
    
    @discardableResult
    private func callExpression(string: String) -> Object {
        let cons = self.reader.read(input: string)
        return self.evaluator.eval(expression: cons, environment: self.environment)
    }

}
