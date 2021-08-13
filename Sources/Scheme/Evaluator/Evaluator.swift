//
//  File.swift
//  
//
//  Created by Niklas Schildhauer on 21.07.21.
//

import Foundation

class Evaluator {
    /// This stack contains the objects that are to be evaluated.
    private var evalStack: Stack = Stack<Object>()
    
    init() { }
}

//  MARK: Protocol conformance
/// This extension conforms the evaluator class  to the Evaluating protocol. These functions are visible for the
/// other files of the interpreter.
extension Evaluator: SchemeEvaluatorProtocol {
    //Layer 1
    func eval(expression: Object, environment: SchemeEnvironment) -> Object{
        switch expression {
        case .Cons(let cons):
            return self.eval(list: cons, environment: environment)
        case .Symbol(let symbol):
            guard let knownValue = environment.get(key: symbol) else { return .Null }
            return knownValue
        default: return expression
        }
    }
    
    func initializeBuiltInFunctions(in environment: SchemeEnvironment) {
        environment.insertOrUpdate(key: .init(value: "+"), value: .BuiltInFunction(value: .init(code: plus)))
        environment.insertOrUpdate(key: .init(value: "-"), value: .BuiltInFunction(value: .init(code: minus)))
        environment.insertOrUpdate(key: .init(value: "*"), value: .BuiltInFunction(value: .init(code: times)))
        environment.insertOrUpdate(key: .init(value: "eq?"), value: .BuiltInFunction(value: .init(code: eq)))
        environment.insertOrUpdate(key: .init(value: "="), value: .BuiltInFunction(value: .init(code: eqnr)))
        environment.insertOrUpdate(key: .init(value: "<"), value: .BuiltInFunction(value: .init(code: stnr)))
        environment.insertOrUpdate(key: .init(value: ">"), value: .BuiltInFunction(value: .init(code: gtnr)))
        environment.insertOrUpdate(key: .init(value: "display"), value: .BuiltInFunction(value: .init(code: display)))
        environment.insertOrUpdate(key: .init(value: "cons"), value: .BuiltInFunction(value: .init(code: cons)))
        environment.insertOrUpdate(key: .init(value: "car"), value: .BuiltInFunction(value: .init(code: car)))
        environment.insertOrUpdate(key: .init(value: "cdr"), value: .BuiltInFunction(value: .init(code: cdr)))
    }
    
    func initializeBuiltInSyntax(in environment: SchemeEnvironment) {
        environment.insertOrUpdate(key: .init(value: "define"), value: .Syntax(value: .init(type: .Define)))
        environment.insertOrUpdate(key: .init(value: "if"), value: .Syntax(value: .init(type: .If)))
        environment.insertOrUpdate(key: .init(value: "set!"), value: .Syntax(value: .init(type: .Set)))
        environment.insertOrUpdate(key: .init(value: "begin"), value: .Syntax(value: .init(type: .Begin)))
        environment.insertOrUpdate(key: .init(value: "lambda"), value: .Syntax(value: .init(type: .Lambada)))
        environment.insertOrUpdate(key: .init(value: "quote"), value: .Syntax(value: .init(type: .Quote)))
    }
}

// MARK: Implementation of the evaluator
private extension Evaluator {
    //Layer 2
    private func eval(list: SchemeCons, environment: SchemeEnvironment) -> Object {
        let funcOrSyntax = self.eval(expression: list.car, environment: environment)
        guard let args = list.cdr.consObject() else {
            return .Error(message: "The list has no arguments")
        }
        
        switch funcOrSyntax {
        case .Syntax(let syntaxObject):
            switch syntaxObject.type {
            case .Define:
                let userdefinedFunction = self.evalSyntax(define: syntaxObject, in: environment, with: args)
                return userdefinedFunction
            case .Begin:
                return self.evalSyntax(begin: syntaxObject, in: environment, with: args)
            case .If:
                return self.evalSyntax(if: syntaxObject, in: environment, with: args)
            case .Set:
                return self.evalSyntax(set: syntaxObject, in: environment, with: args)
            case .Lambada:
                let userdefinedFunction = self.evalSyntax(lambda: syntaxObject, in: environment, with: args)
                return userdefinedFunction
            case .Quote:
                return self.evalSyntax(quote: syntaxObject, in: environment, with: args)
            }
        case .BuiltInFunction(let function):
            let currentPointer = self.evalStack.currentPointer
            self.evalFunction(args: args, in: environment)
            return function.code(currentPointer, self.evalStack)
        case .UserDefinedFunction(let userDefined):
            // (define (<= a b) (> a b))
            // Eingabe; (<= 123 3)
            
            // Neues Environment von der Funktion
            let funcEnvironment = Environment(parentEnvironment: userDefined.homeEnvironment)
            let firstArgIndex = self.evalStack.currentPointer
            self.evalFunction(args: args, in: environment)
            
            // a b
            var argListName = userDefined.argList // diese argLists werden hier zugeordnet
            // 123 3
            let argListValue = self.evalStack.getObjects(from: firstArgIndex)
            
            for value in argListValue {
                guard let name = argListName.car.symbolObject() else {
                    return .Error(message: "There went somethin wrong")
                }
                if argListName.cdr != .Null {
                    argListName = argListName.cdr.consObject()! // Nicht swifty... 
                }
                funcEnvironment.insertOrUpdate(key: name, value: value)
            }
            
            let bodyList = userDefined.bodyList
            return self.evalUserDefinedFunction(bodyList: bodyList, in: funcEnvironment)
        default:
            return .Null
        }
    }
    
    //Helper
    private func evalFunction(args: SchemeCons?, in environment: SchemeEnvironment) {
        guard let args = args else { return }
        if args.car == .Null {
            return
        }
        let evaluatedArg = self.eval(expression: args.car, environment: environment)
        self.evalStack.push(object: evaluatedArg)
        
        guard let nextArgs = args.cdr.consObject() else { return }
        self.evalFunction(args: nextArgs, in: environment)
    }
    
    private func evalUserDefinedFunction(bodyList: SchemeCons, in environment: SchemeEnvironment) -> Object {
        let retVal = self.eval(expression: bodyList.car, environment: environment)
        guard let restArgs = bodyList.cdr.consObject() else {
            return retVal
        }
        return self.evalUserDefinedFunction(bodyList: restArgs, in: environment)
    }
        
    private func evalSyntax(define: SchemeSyntax, in environment: SchemeEnvironment, with args: SchemeCons) -> Object {
  
        // (define varname 123)
        //         _ ___  varvalue
        // OR
        // (define (funcname var var) (+ var var))
        //          -------  arglist   bodylist
        let varOrFunc = args.car
        
        if let varName = varOrFunc.symbolObject() {
            guard let restArg = args.cdr.consObject() else {
                return .Error(message: "(define): 2 args expected")
            }
            
            if restArg.cdr != .Null {
                return .Error(message: "(define): only 2 args expected")
            }
            
            let varValue = self.eval(expression: restArg.car, environment: environment)
            
            environment.insertOrUpdate(key: varName, value: varValue)
            return .Null // Hier will ich Null zurückgeben! -> D.h. es wurde defined
            
        } else {
            // (define (funcname var var) (+ var var)) -> shorthand lambda
            //          -------  arglist   bodylist
            guard let cons = varOrFunc.consObject() else {
                return .Error(message: "Bad arg. Es sollte ein Cons Objekt sein")
            }
            
            guard let funcName = cons.car.symbolObject() else {
                return .Error(message: "Bad function name. Es sollte ein Symbol Objekt sein")
            }
            
            guard let argList = cons.cdr.consObject() else {
                return .Error(message: "Bad arg name list")
            }
            
            if !self.isValidFormalArgList(args: argList) {
                return .Error(message: "Bad arg name list")
            }
            
            // (+ var var)
            guard let bodyList = args.cdr.consObject() else {
                return .Error(message: "Body List is no cons")
            }
            
            let function = Object.UserDefinedFunction(value: .init(homeEnvironment: environment, argList: argList, bodyList: bodyList))
            environment.insertOrUpdate(key: funcName, value: function)
            return .Null
        }
    }
    
    // Helper
    private func isValidFormalArgList(args: SchemeCons) -> Bool {
        if args.car.symbolObject() == nil {
            return false
        }
        if let restArgs = args.cdr.consObject() {
            return self.isValidFormalArgList(args: restArgs)
        }
        return true
    }
        
    private func evalSyntax(begin: SchemeSyntax, in environment: SchemeEnvironment, with args: SchemeCons) -> Object{
        // WAS SOLL HIER NUR REIN
        .Null
    }
    
    private func evalSyntax(set: SchemeSyntax, in environment: SchemeEnvironment, with args: SchemeCons) -> Object {
        guard let varName = args.car.symbolObject(),
              let restArgs = args.cdr.consObject(),
              let unevaluatedVarValue = args.cdr.consObject()?.car else {
                return .Error(message: "(set!): 2 args expected")
        }
        
        if restArgs.cdr != .Null {
            return .Error(message: "(set!): only 2 args expected")
        }
        
        let varValue = self.eval(expression: unevaluatedVarValue, environment: environment)
        if environment.update(key: varName, value: varValue) == false {
            return .Error(message: "(set!) - There is no binding for \(varName.characters)")
        }
        
        return .Void
    }
    
    private func evalSyntax(if: SchemeSyntax, in environment: SchemeEnvironment, with args: SchemeCons) -> Object {
        let unevaluatedCond = args.car
        guard let trueExpr = args.cdr.consObject()?.car,
              let falseExpr = args.cdr.consObject()?.cdr.consObject()?.car else {
            return .Error(message: "(if): 3 args expected")
        }
        if unevaluatedCond == .Null || trueExpr == .Null || falseExpr == .Null {
            return .Error(message: "(if): 3 args expected")
        }
        
        let condition = self.eval(expression: unevaluatedCond, environment: environment)
        
        switch condition {
        case .True:
            return self.eval(expression: trueExpr, environment: environment)
        case .False:
            return self.eval(expression: falseExpr, environment: environment)
        default:
            return .Error(message: "non binary condition")
        }
    }
    
    private func evalSyntax(lambda: SchemeSyntax, in environment: SchemeEnvironment, with args: SchemeCons) -> Object {
        guard let argList = args.car.consObject() else {
            return .Error(message: "Args erwartet")
        }
        guard let bodyList = args.cdr.consObject() else {
            return .Error(message: "Mindestend 2 args erwartet")
        }
        
        return .UserDefinedFunction(value: .init(homeEnvironment: environment, argList: argList, bodyList: bodyList))
    }
    
    private func evalSyntax(quote: SchemeSyntax, in environment: SchemeEnvironment, with args: SchemeCons) -> Object {
        if args.car == .Null {
            return .Error(message: "(Quote): 1 arg erwartet")
        }
        
        if args.cdr != .Null {
            return .Error(message: "(Quote): genau 1 arg erwartet")
        }
        return args.car
    }
}


