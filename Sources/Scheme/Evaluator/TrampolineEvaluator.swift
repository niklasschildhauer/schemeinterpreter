//
//  TrampolineEvaluator.swift
//  
//
//  Created by Niklas Schildhauer on 30.07.21.
//

import Foundation

/// Evaluating Protocol to define the functions which are called by the interpreter class
protocol SchemeEvaluatorProtocol {
    func initializeBuiltInFunctions(in environment: SchemeEnvironment)
    func initializeBuiltInSyntax(in environment: SchemeEnvironment)
    func eval(expression: Object, environment: SchemeEnvironment) -> Object
}

//  MARK: Implementation Trampoline Evaluator
/// This Evaluator uses a trampoline to avoid to fill the stack with recursive function calls.
/// In Evaluator.swift is another implementation of the Evaluator without the trmapoline. 
class TrampolineEvaluator {
    /// The return value which is passed back after the trampoline execution
    private var retVal: Object = .Null
    /// This stack contains the objects that are to be evaluated.
    private var evalStack: Stack = Stack<Object>()
    /// This stack contains all functions which should execute after each other
    private var continuationStack: Stack = Stack<(() -> Void)?>()

    init() { }
    
}

//  MARK: Protocol conformance
/// This extension conforms the trampoline evaluator class to the Evaluating protocol. These functions are visible for the
/// other files of the interpreter.
extension TrampolineEvaluator: SchemeEvaluatorProtocol {
    /// This function is called to evaluate an object, which was read from the reader
    /// It returns the evaluated result in form of an object.
    /// This functions starts the trampoline function to start it.
    func eval(expression: Object, environment: SchemeEnvironment) -> Object {
        // Reset the retVal. Not necessary
        self.retVal = .Null
        // At first the expression and the environment is pushed to the stack
        // These are required from the evalContinuation function.
        evalStack.push(object: expression)
        evalStack.push(object: .Environment(value: environment))
        
        // Start the trampoline with the eval function
        self.trampoline(startFunction: evalContinuation)
        return retVal
    }
    
    /// This function initializes the built in functions. It inserts all built in functions to the environment.
    func initializeBuiltInFunctions(in environment: SchemeEnvironment) {
        environment.insertOrUpdate(key: .init(value: "+"), value: .BuiltInFunction(value: .init(code: plus)))
        environment.insertOrUpdate(key: .init(value: "-"), value: .BuiltInFunction(value: .init(code: minus)))
        environment.insertOrUpdate(key: .init(value: "*"), value: .BuiltInFunction(value: .init(code: times)))
        environment.insertOrUpdate(key: .init(value: "%"), value: .BuiltInFunction(value: .init(code: remainder)))
        environment.insertOrUpdate(key: .init(value: "/"), value: .BuiltInFunction(value: .init(code: quotient)))
        environment.insertOrUpdate(key: .init(value: "eq?"), value: .BuiltInFunction(value: .init(code: eq)))
        environment.insertOrUpdate(key: .init(value: "="), value: .BuiltInFunction(value: .init(code: eqnr)))
        environment.insertOrUpdate(key: .init(value: "<"), value: .BuiltInFunction(value: .init(code: stnr)))
        environment.insertOrUpdate(key: .init(value: ">"), value: .BuiltInFunction(value: .init(code: gtnr)))
        environment.insertOrUpdate(key: .init(value: "display"), value: .BuiltInFunction(value: .init(code: display)))
        environment.insertOrUpdate(key: .init(value: "truncate"), value: .BuiltInFunction(value: .init(code: truncate)))
        environment.insertOrUpdate(key: .init(value: "print"), value: .BuiltInFunction(value: .init(code: print)))
        environment.insertOrUpdate(key: .init(value: "cons"), value: .BuiltInFunction(value: .init(code: cons)))
        environment.insertOrUpdate(key: .init(value: "car"), value: .BuiltInFunction(value: .init(code: car)))
        environment.insertOrUpdate(key: .init(value: "cdr"), value: .BuiltInFunction(value: .init(code: cdr)))
        environment.insertOrUpdate(key: .init(value: "load"), value: .BuiltInFunction(value: .init(code: load)))
        
        
        /// String functions
        environment.insertOrUpdate(key: .init(value: "string-ref"), value: .BuiltInFunction(value: .init(code: stringRef)))
        environment.insertOrUpdate(key: .init(value: "string-length"), value: .BuiltInFunction(value: .init(code: stringLength)))
        environment.insertOrUpdate(key: .init(value: "string-append"), value: .BuiltInFunction(value: .init(code: stringAppend)))
        environment.insertOrUpdate(key: .init(value: "string=?"), value: .BuiltInFunction(value: .init(code: stringEqual)))
        
        /// Question functions
        environment.insertOrUpdate(key: .init(value: "string?"), value: .BuiltInFunction(value: .init(code: stringQuestion)))
        environment.insertOrUpdate(key: .init(value: "bool?"), value: .BuiltInFunction(value: .init(code: boolQuestion)))
        environment.insertOrUpdate(key: .init(value: "number?"), value: .BuiltInFunction(value: .init(code: numberQuestion)))
        environment.insertOrUpdate(key: .init(value: "cons?"), value: .BuiltInFunction(value: .init(code: consQuestion)))
        environment.insertOrUpdate(key: .init(value: "builtin-function?"), value: .BuiltInFunction(value: .init(code: builtinFunctionQuestion)))
        environment.insertOrUpdate(key: .init(value: "user-function?"), value: .BuiltInFunction(value: .init(code: userFunctionQuestion)))
        environment.insertOrUpdate(key: .init(value: "function?"), value: .BuiltInFunction(value: .init(code: functionQuestion)))
     

        // Does not work properly
        environment.insertOrUpdate(key: .init(value: "eval"), value: .TrampolineFunction(value: .init(code: trampolineFunctionEval)))
    }
    
    /// This function initializes the built in syntax. It inserts all built in syntax  to the environment.
    func initializeBuiltInSyntax(in environment: SchemeEnvironment) {
        environment.insertOrUpdate(key: .init(value: "define"), value: .Syntax(value: .init(type: .Define)))
        environment.insertOrUpdate(key: .init(value: "if"), value: .Syntax(value: .init(type: .If)))
        environment.insertOrUpdate(key: .init(value: "set!"), value: .Syntax(value: .init(type: .Set)))
        environment.insertOrUpdate(key: .init(value: "begin"), value: .Syntax(value: .init(type: .Begin)))
        environment.insertOrUpdate(key: .init(value: "lambda"), value: .Syntax(value: .init(type: .Lambada)))
        environment.insertOrUpdate(key: .init(value: "quote"), value: .Syntax(value: .init(type: .Quote)))
    }
}

//  MARK: Trampoline
/// This extension contains the trampoline function, which is the core function of the evaluator
private extension TrampolineEvaluator {
    
    /// This function is called by the  eval(expression: Object, environment: SchemeEnvironment) function
    /// and executes each continuation function after each other from the continuation stack.
    private func trampoline(startFunction: @escaping () -> Void) {
        var nextCont: (() -> Void)? = startFunction
        
        // Push nil to continuation stack as stop element
        continuationStack.push(object: nil)
        while nextCont != nil {
            guard let nextFunctionCall = nextCont else { return }
            nextFunctionCall()
            nextCont = continuationStack.pop()
        }
    }
}

// MARK: Layer 1 - Eval function
private extension TrampolineEvaluator {
    /// This function takes the object to be evaluated from the stack and checks if it is a cons or a symbol otherwise it is the retval.
    private func evalContinuation() -> Void {
        // expects on eval stack: expression and environment
        guard let environment: SchemeEnvironment = self.evalStack.pop().environmentObject() else {
            return self.raiseFatalError(message: "Eval stack bug")
        }
        
        let expression: Object = self.evalStack.pop()
        switch expression {
        case .Symbol(let symbol):
            // It is a symbol so there should be a binding in the environment.
            guard let knownValue = environment.get(key: symbol) else {
                return self.raiseInputError(message: "It exists no known binding for \"\(symbol.characters)\"")
            }
            self.retVal = knownValue
            return
        case .Cons(_):
            // It is a list. For this reason, it can be anything (cons, list, function,...),
            // which is why layer 2 function eval list is called (or pushed to cont stack)
            self.evalStack.push(object: expression)
            self.evalStack.push(object: Object.Environment(value: environment))
            self.continuationStack.push(object: self.evalListContinuation)
            return
        default:
            self.retVal = expression
            return
        }
    }
}

// MARK: Layer 2 - Eval List
private extension TrampolineEvaluator {
    
    /// This function prepares the cons to be evaluated from evalListContinuationFirst( ).
    /// It returns two cont:
    /// 1. evalContinuation( ) of the car (-> is it a function or syntax?)
    /// 2. eval list continuation first to go forward with the next eval step.
    private func evalListContinuation() -> Void {
        // expects on eval stack: expression and environment
        guard let environment: SchemeEnvironment = self.evalStack.pop().environmentObject(),
              let expression: SchemeCons = self.evalStack.pop().consObject() else {
            return self.raiseFatalError(message: "Eval stack bug")
        }
        // stack should be empty now
        let restArgs = expression.cdr
        
        // preserve for evalListContinuationFirst()
        self.evalStack.push(object: Object.Environment(value: environment))
        self.evalStack.push(object: restArgs)
        // args for evalContinuation()
        self.evalStack.push(object: expression.car)
        self.evalStack.push(object: Object.Environment(value: environment))
      
        self.continuationStack.push(object: self.evalListContinuationFirst)
        self.continuationStack.push(object: self.evalContinuation)
        return
    }
    
    /// Is called after the car of the cons is evaluated. This function checks whether it is a syntax or function.
    /// Therefore the next continuation function will be pushed -> Layer 3.
    private func evalListContinuationFirst() -> Void {
        let funcOrSyntax = self.retVal // because we have called evalContinuation in evalListContinuation, the value is passed via retVal.
        
        // preserved locals from stack
        let restArgs = self.evalStack.pop()
        guard let environment = self.evalStack.pop().environmentObject() else {
            return self.raiseFatalError(message: "Eval stack bug")
        }
        
        switch funcOrSyntax {
        case .Syntax(_):
            // The object is a syntax object so continue with evalSyntax().
            self.evalStack.push(object: funcOrSyntax)
            self.evalStack.push(object: restArgs)
            self.evalStack.push(object: Object.Environment(value: environment))
            self.continuationStack.push(object: self.evalSyntax)
            return
        case .BuiltInFunction(_), .UserDefinedFunction(_):
            // The object is a function.
            // This means that all arguments must be evaluated before it can be continued in evalListContinuationThrid
            self.evalStack.push(object: funcOrSyntax)
            
            // push the first arg index. Important! This is needed in evalListContinuationThrid
            self.evalStack.push(object: .Integer(value: self.evalStack.currentPointer))
            
            if restArgs != .Null {
                guard let restArgsList = restArgs.consObject() else {
                    return self.raiseFatalError(message: "No cons object found")
                }
                let nextArg = restArgsList.car
                self.evalStack.push(object: restArgs)
                self.evalStack.push(object: .Environment(value: environment))
                
                self.evalStack.push(object: nextArg)
                self.evalStack.push(object: .Environment(value: environment))
                
                self.continuationStack.push(object: self.evalListContinuationSecond)
                self.continuationStack.push(object: self.evalContinuation)
                
                return
            }
            // if there is nothing to evaluate continue with evalListContinuationThrid()
            self.continuationStack.push(object: self.evalListContinuationThrid)
            return
        case .TrampolineFunction(_):
            // special case which should be improved. WIP
            self.evalStack.push(object: funcOrSyntax)
            self.evalStack.push(object: restArgs)
            self.evalStack.push(object: Object.Environment(value: environment))
            self.continuationStack.push(object: self.evalTrampolineFunction)
            return
        default:
            return self.raiseInputError(message: "The car of the cons is not a function or syntax. This is not valid!")
        }
    }
    
    /// This function is called evaluated the restArgs of a list.
    private func evalListContinuationSecond() -> Void {
        guard let environment = self.evalStack.pop().environmentObject(),
              let restArgsList = self.evalStack.pop().consObject(),
              let firstArgIndex = self.evalStack.pop().intValue() else {
            return self.raiseFatalError(message: "Eval stack bug")
        }
      
        let nextEvaluatedArg = self.retVal
        
        self.evalStack.push(object: nextEvaluatedArg)
        // The first arg index is pushed again to the stack
        self.evalStack.push(object: .Integer(value: firstArgIndex))
        
        let restArgs = restArgsList.cdr
        
        if restArgs != .Null {
            guard let restArgsList = restArgs.consObject() else {
                return self.raiseFatalError(message: "Args are not wrapped in a cons")
            }
            let nextArg = restArgsList.car
            self.evalStack.push(objects: [restArgs, .Environment(value: environment)])
            
            self.evalStack.push(objects: [nextArg, .Environment(value: environment)])
            
            self.continuationStack.push(object: evalListContinuationSecond)
            self.continuationStack.push(object: self.evalContinuation)

            // So werden erst alle Args evaluiert
            return
        }
        // All rest args are evaluated so it can continue with evalListContinuationThrid()
        self.continuationStack.push(object: self.evalListContinuationThrid)

        return
    }
}

// MARK: Layer 3 - Eval function
private extension TrampolineEvaluator {
    
    /// This function is called after all args are evaluated and it is clear that the list is a function.
    private func evalListContinuationThrid() -> Void {
        guard let firstArgIndex = self.evalStack.pop().intValue() else {
            return self.raiseFatalError(message: "Eval stack bug")
        }
        let function = self.evalStack.get(index: firstArgIndex - 1)
        
        switch function {
        case .BuiltInFunction(let function):
            // calls a layer 4 function -> BuiltInFunctions.swift 
            self.retVal = function.code(firstArgIndex, self.evalStack)
            // Pop Function from evalStack
            _ = self.evalStack.pop()
            return
        case .UserDefinedFunction(let value):
            // user defined function with lambda arg & bodylist
            // (lambda (a b c) (body list))
            
            // creates the functions environment
            let functionEnvironment = Environment(parentEnvironment: value.homeEnvironment)
            var argListName = value.argList
            let argListValue = self.evalStack.getObjects(from: firstArgIndex)
            
            for value in argListValue {
                guard let name = argListName.car.symbolObject() else {
                    return self.raiseFatalError(message: "Args are not wrapped in a cons")
                }
                if argListName.cdr != .Null {
                    argListName = argListName.cdr.consObject()! // Nicht swifty...
                }
                
                functionEnvironment.insertOrUpdate(key: name, value: value)
            }
            
            if argListName.cdr != .Null {
                return self.raiseInputError(message: "Not enough arguments in function")
            }
            // Pop Function from evalStack
            _ = self.evalStack.pop()
            
            let bodyList = value.bodyList
            
            if bodyList.car != .Null {
                let nextBodyExpression = bodyList.car
                
                if bodyList.cdr == .Null {
                    // last expression in bodylist
                    // --> tailcall
                    self.evalStack.push(object: nextBodyExpression)
                    self.evalStack.push(object: .Environment(value: functionEnvironment))
                    
                    self.continuationStack.push(object: self.evalContinuation)
                    return
                }
                
                // preserve functionsEnv and restBodyList
                self.evalStack.push(object: .Environment(value: functionEnvironment))
                self.evalStack.push(object: .Cons(value: bodyList))
                
                // args for evalContinuation()
                self.evalStack.push(object: nextBodyExpression)
                self.evalStack.push(object: .Environment(value: functionEnvironment))

                self.continuationStack.push(object: self.evalListContinuationFourth)
                self.continuationStack.push(object: self.evalContinuation)

                return
            }
        
            // Only arrive here for an empty body.
            // This is not allowed in this Scheme Interpreter.
            return self.raiseInputError(message: "No empty body allowed.")
            
        default:
            return self.raiseFatalError(message: "This should never happen")
        }
    }

    /// This function evaluates the rest body list
    private func evalListContinuationFourth() -> Void {
        guard let restBodyList = self.evalStack.pop().consObject(),
              let functionsEnvironment = self.evalStack.pop().environmentObject() else {
            return self.raiseFatalError(message: "Eval stack bug")
        }
        
        let restBody = restBodyList.cdr
        if restBody == .Null {
            return self.raiseFatalError(message: "This should never happen")
        }
        
        guard let restBodyList2 = restBody.consObject() else {
            return self.raiseFatalError(message: "This sould never happen")
        }
        let nextBodyExpression = restBodyList2.car

        if restBodyList2.cdr == .Null {
            // last expression in bodylist
            // --> tailcall
            self.evalStack.push(object: nextBodyExpression)
            self.evalStack.push(object: .Environment(value: functionsEnvironment))
            
            self.continuationStack.push(object: self.evalContinuation)
            return
        }

        // preserve environment and bodyList for cont4
        self.evalStack.push(object: .Environment(value: functionsEnvironment))
        self.evalStack.push(object: restBody)
        
        self.evalStack.push(object: nextBodyExpression)
        self.evalStack.push(object: .Environment(value: functionsEnvironment))
        
        self.continuationStack.push(object: evalListContinuationFourth)
        self.continuationStack.push(object: self.evalContinuation)
        return
    }
}

// MARK: Layer 4 - Trampoline Functions -> (eval .. ..)
private extension TrampolineEvaluator {
    
    private func evalTrampolineFunction() -> Void {
        guard let environment = self.evalStack.pop().environmentObject(),
              let argList = self.evalStack.pop().consObject(),
              let function = self.evalStack.pop().trampolineFunctionObject() else {
            return self.raiseFatalError(message: "Eval stack bug")
        }
        
        function.code(argList, environment)
    }
    
    private func trampolineFunctionEval(argList: SchemeCons, environment: SchemeEnvironment) -> Void {
        if argList.cdr != .Null {
            return self.raiseInputError(message: "(eval) - allows only one argument")
        }
        
        self.evalStack.push(object: argList.car)
        self.evalStack.push(object: .Environment(value: environment))
        self.continuationStack.push(object: self.trampolineFunctionEval_Cont1)
    }
    
    private func trampolineFunctionEval_Cont1() -> Void {
        guard let environment = self.evalStack.pop().environmentObject() else {
            return self.raiseFatalError(message: "There went something wrong")
        }
        let expression = self.evalStack.pop()
        
        self.retVal = self.eval(expression: expression, environment: environment)
    }
}

// MARK: Layer 4 - Eval Syntax
private extension TrampolineEvaluator {
    
    /// This functinos pops the syntax object and switches over the type. Afterwards the syntax function is called.
    private func evalSyntax() -> Void {
        guard let environment = self.evalStack.pop().environmentObject(),
              let argList = self.evalStack.pop().consObject(),
              let syntaxObject = self.evalStack.pop().syntaxObject() else {
            return self.raiseFatalError(message: "Eval stack bug")
        }
        
        switch syntaxObject.type {
        case .Define: return self.evalDefineSyntax(define: syntaxObject, in: environment, with: argList)
        case .Begin: return self.evalBeginSyntax(begin: syntaxObject, in: environment, with: argList)
        case .If: return self.evalIfSyntax(if: syntaxObject, in: environment, with: argList)
        case .Set: return self.evalSetSyntax(set: syntaxObject, in: environment, with: argList)
        case .Lambada: return self.evalLambdaSyntax(lambda: syntaxObject, in: environment, with: argList)
        case .Quote: return self.evalQuoteSyntax(quote: syntaxObject, in: environment, with: argList)
        }
    }
    
    /// Function to eval the begin syntax
    private func evalBeginSyntax(begin: SchemeSyntax, in environment: SchemeEnvironment, with args: SchemeCons) {
        // (begin expr1 ... exprN)
        let nextExpression = args.car
        
        if (nextExpression == .Null ) {
            self.retVal = .Void
            return
        }
        
        if args.cdr == .Null {
            // tailcall last expr -> args to eval
            self.evalStack.push(objects: [nextExpression, Object.Environment(value: environment)])
            self.continuationStack.push(object: evalContinuation)
            return
        }
        // preserved locals
        self.evalStack.push(objects: [Object.Environment(value: environment), Object.Cons(value: args)])
        // args to eval
        self.evalStack.push(objects: [nextExpression, Object.Environment(value: environment)])
        
        self.continuationStack.push(object: beginContinuationFirst)
        self.continuationStack.push(object: evalContinuation)
        
        return
    }
    
    /// Continuation of the begin function. After args are evaluated.
    private func beginContinuationFirst() -> Void {
        guard let args = self.evalStack.pop().consObject() else {
            self.raiseFatalError(message: "This should never happen")
            return
        }
        let environment = self.evalStack.pop()
        
        let restArgList = args.cdr
        if restArgList != .Null {
            guard let nextExpression = restArgList.consObject()?.car else {
                return
            }
            
            if restArgList.consObject()?.cdr == .Null {
                // tailcall last expr. -> args to eval
                self.evalStack.push(objects: [nextExpression, environment])
                self.continuationStack.push(object: evalContinuation)
                return
            }
            // preserved locals
            self.evalStack.push(objects: [environment, restArgList])
            // args to eval
            self.evalStack.push(objects: [nextExpression, environment])
            
            self.continuationStack.push(objects: [beginContinuationFirst, evalContinuation])
            return
        }
        return
    }

    /// Function to eval the if syntax
    private func evalIfSyntax(if: SchemeSyntax, in environment: SchemeEnvironment, with args: SchemeCons) {
        let unevaluatedCond = args.car
        guard let trueExpr = args.cdr.consObject()?.car,
              let falseExpr = args.cdr.consObject()?.cdr.consObject()?.car else {
            return self.raiseInputError(message: "(if) - requires 3 args")
        }
        if unevaluatedCond == .Null || trueExpr == .Null || falseExpr == .Null {
            return self.raiseInputError(message: "(if) - requires 3 args")
        }
        
        // for continuation
        evalStack.push(object: .Environment(value: environment))
        evalStack.push(object: trueExpr)
        evalStack.push(object: falseExpr)

        // eval the condition
        evalStack.push(object: unevaluatedCond)
        evalStack.push(object: .Environment(value: environment))
        
        continuationStack.push(object: self.ifContinuationFirst)
        self.continuationStack.push(object: self.evalContinuation)

        return
    }
    
    /// Continuation of the if function. After args are evaluated.
    private func ifContinuationFirst() -> Void {
        let condition = self.retVal
        let falseExpr = self.evalStack.pop()
        let trueExpr = self.evalStack.pop()
        guard let environment = self.evalStack.pop().environmentObject() else {
            return self.raiseFatalError(message: "Eval stack error")
        }
        
        switch condition {
        case .True:
            self.evalStack.push(object: trueExpr)
            self.evalStack.push(object: .Environment(value: environment))
        case .False:
            self.evalStack.push(object: falseExpr)
            self.evalStack.push(object: .Environment(value: environment))
        default:
            return self.raiseInputError(message: "(if) - the condition is not a binary")
        }
        self.continuationStack.push(object: self.evalContinuation)
        return
    }

    /// Function to eval the set syntax
    private func evalSetSyntax(set: SchemeSyntax, in environment: SchemeEnvironment, with args: SchemeCons) {
        guard let varName = args.car.symbolObject(),
              let restArgs = args.cdr.consObject(),
              let unevaluatedVarValue = args.cdr.consObject()?.car else {
            return self.raiseInputError(message: "(set!) - requires 2 args")
        }
        
        if restArgs.cdr != .Null {
            return self.raiseInputError(message: "(set!) - requires 2 args")
        }
        // for continuation
        evalStack.push(object: .Symbol(value: varName))
        evalStack.push(object: .Environment(value: environment))
        
        // to eval
        evalStack.push(object: unevaluatedVarValue)
        evalStack.push(object: .Environment(value: environment))

        continuationStack.push(object: setContinuationFirst)
        self.continuationStack.push(object: self.evalContinuation)

        return
    }
    
    /// Continuation of the set function. After args are evaluated.
    private func setContinuationFirst() -> Void {
        let varValue = self.retVal
        guard let environment = self.evalStack.pop().environmentObject(),
              let varName = self.evalStack.pop().symbolObject()  else {
            return self.raiseFatalError(message: "Eval stack error")
        }
        
        environment.insertOrUpdate(key: varName, value: varValue)
        
        self.retVal = .Void
        return
    }

    /// Function to eval the lambda syntax
    private func evalLambdaSyntax(lambda: SchemeSyntax, in environment: SchemeEnvironment, with args: SchemeCons) {
        guard let argList = args.car.consObject() else {
            return self.raiseInputError(message: "(lambda) - requires args")
        }
        guard let bodyList = args.cdr.consObject() else {
            return self.raiseInputError(message: "(lambda) - requires min 2 args")
        }
        
        retVal = .UserDefinedFunction(value: .init(homeEnvironment: environment, argList: argList, bodyList: bodyList))
        
        return
    }

    /// Function to eval the quote syntax
    private func evalQuoteSyntax(quote: SchemeSyntax, in environment: SchemeEnvironment, with args: SchemeCons) {
        if args.car == .Null {
            return self.raiseInputError(message: "(quote) - requires 1 arg")
        }
        
        if args.cdr != .Null {
            return self.raiseInputError(message: "(quote) - requires only 1 arg")
        }
        
        retVal = args.car
        return
    }

    /// Function to eval the define syntax
    private func evalDefineSyntax(define: SchemeSyntax, in environment: SchemeEnvironment, with args: SchemeCons) {
        // Could be:
        // (define varname 123)
        // or
        // (define (funcname var var) (+ var var))
        let varOrFunc = args.car
        
        if let varName = varOrFunc.symbolObject() {
            // simple define (define var expr)
            guard let restArg = args.cdr.consObject() else {
                return self.raiseInputError(message: "(define) - requires 2 args")
            }
            
            if restArg.cdr != .Null {
                return self.raiseInputError(message: "(define) - requires only 2 args")
            }
            
            // preserve
            evalStack.push(object: .Symbol(value: varName))
            evalStack.push(object: .Environment(value: environment))
            
            // evaluate the args before cdefine is called
            evalStack.push(object: restArg.car) // restArg.car = unevaluatedVarValue
            evalStack.push(object: .Environment(value: environment))

            continuationStack.push(object: defineContinuationFirst)
            continuationStack.push(object: self.evalContinuation)
            
            return
            
        } else {
            // (define (funcname var var) (+ var var)) -> shorthand lambda
            //          -------  arglist   bodylist
            guard let cons = varOrFunc.consObject(),
                  let funcName = cons.car.symbolObject(),
                  let argList = cons.cdr.consObject() else {
                return self.raiseFatalError(message: "Parse error")
            }
            
            if !isValidFormalArgList(args: argList) {
                return self.raiseInputError(message: "(define) - bad args name list")
            }
            
            // (+ var var)
            guard let bodyList = args.cdr.consObject() else {
                return self.raiseInputError(message: "(define) - bad body list")
            }
            
            let function = Object.UserDefinedFunction(value: .init(homeEnvironment: environment, argList: argList, bodyList: bodyList))
            environment.insertOrUpdate(key: funcName, value: function)
            retVal = .Void
            return
        }
    }
    
    /// Continuation of the define function. After body list and arg list are evaluated.
    private func defineContinuationFirst() -> Void {
        let varValue = self.retVal
        
        guard let environment = self.evalStack.pop().environmentObject(),
              let varName = self.evalStack.pop().symbolObject() else {
            return self.raiseFatalError(message: "Eval stack error")
        }
        
        environment.insertOrUpdate(key: varName, value: varValue)
        
        self.retVal = .Void
        
        return
    }
}

//  MARK: Helper functions
/// These functions are used to raise or throw an error. They stop the trampoline and set as retVal the error.
extension TrampolineEvaluator {
    // Stops the trampoline and sets as retVal a fatal error
    private func raiseFatalError(message: String, line: Int = #line, function: String = #function) {
        self.retVal = .FatalError(message: message, line: line, function: function, file: #file)
        self.continuationStack.clearStack()
        self.continuationStack.push(object: nil)
    }
    
    // Stops the trampoline and sets as retVal a input error
    private func raiseInputError(message: String, line: Int = #line, function: String = #function) {
        self.retVal = .Error(message: message, line: line, function: function, file: #file)
        self.continuationStack.clearStack()
        self.continuationStack.push(object: nil)
    }
    
    /// Helper function to check if the arg list is valid
    private func isValidFormalArgList(args: SchemeCons) -> Bool {
        if args.car.symbolObject() == nil {
            return false
        }
        if let restArgs = args.cdr.consObject() {
            return isValidFormalArgList(args: restArgs)
        }
        return true
    }
}
