////
////  File.swift
////
////
////  Created by Niklas Schildhauer on 30.07.21.
////
//
//import Foundation
//
//private struct SchemeContinuationFunction {
//    let function: () -> SchemeContinuationFunction?
//}
//
//
//// Wegen Tail call eliminierung
//// Wir wollen den Stack nicht ewig füllen mit Rekursion.
//// Ist also für die Rekursion von Scheme da -> Wir rufen in Scheme dieselbe Funktion nochmals auf
//class T_Evaluator {
//    init() {}
//    
//    fileprivate func trampoline(startFunction: SchemeContinuationFunction) {
//        var nextCont: SchemeContinuationFunction? = startFunction
//        
//        continuationStack.push(object: nil)
//        while nextCont != nil {
//            //force unwrap -> Bin mir sicher dass es nicht nil ist.
//            nextCont = nextCont!.function()
//        }
//    }
//}
//
//extension T_Evaluator: Evaluating {
//    func initializeBuiltInFunctions(in environment: SchemeEnvironment) {
//        environment.insertOrUpdate(key: .init(value: "+"), value: .BuiltInFunction(value: .init(function: plus)))
//        environment.insertOrUpdate(key: .init(value: "-"), value: .BuiltInFunction(value: .init(function: minus)))
//        environment.insertOrUpdate(key: .init(value: "*"), value: .BuiltInFunction(value: .init(function: times)))
//        environment.insertOrUpdate(key: .init(value: "eq?"), value: .BuiltInFunction(value: .init(function: eq)))
//        environment.insertOrUpdate(key: .init(value: "="), value: .BuiltInFunction(value: .init(function: eqnr)))
//        environment.insertOrUpdate(key: .init(value: "<"), value: .BuiltInFunction(value: .init(function: stnr)))
//        environment.insertOrUpdate(key: .init(value: ">"), value: .BuiltInFunction(value: .init(function: gtnr)))
//        environment.insertOrUpdate(key: .init(value: "display"), value: .BuiltInFunction(value: .init(function: display)))
//        environment.insertOrUpdate(key: .init(value: "cons"), value: .BuiltInFunction(value: .init(function: cons)))
//        environment.insertOrUpdate(key: .init(value: "car"), value: .BuiltInFunction(value: .init(function: car)))
//        environment.insertOrUpdate(key: .init(value: "cdr"), value: .BuiltInFunction(value: .init(function: cdr)))
////        environment.insertOrUpdate(key: .init(value: "eval"), value: .BuiltInFunction(value: .init(function: self.eval)))
//
//    }
//    
//    func initializeBuiltInSyntax(in environment: SchemeEnvironment) {
//        environment.insertOrUpdate(key: .init(value: "define"), value: .Syntax(value: .init(type: .Define)))
//        environment.insertOrUpdate(key: .init(value: "if"), value: .Syntax(value: .init(type: .If)))
//        environment.insertOrUpdate(key: .init(value: "set!"), value: .Syntax(value: .init(type: .Set)))
//        environment.insertOrUpdate(key: .init(value: "begin"), value: .Syntax(value: .init(type: .Begin)))
//        environment.insertOrUpdate(key: .init(value: "lambda"), value: .Syntax(value: .init(type: .Lambada)))
//        environment.insertOrUpdate(key: .init(value: "quote"), value: .Syntax(value: .init(type: .Quote)))
//    }
//    
//    func eval(expression: Object, environment: SchemeEnvironment) -> Object {
//        evalStack.push(object: expression)
//        evalStack.push(object: .Environment(value: environment))
//        
//        self.trampoline(startFunction: C_eval)
//        return retVal
//    }
//}
//
//
//
//fileprivate var retVal: Object = .Null
//fileprivate var evalStack: Stack = Stack<Object>()
//fileprivate var continuationStack: Stack = Stack<SchemeContinuationFunction?>()
//
////public func startEval(expression: Object, environment: SchemeEnvironment) -> Object {
////    evalStack.push(object: expression)
////    evalStack.push(object: .Environment(value: environment))
////
////    trampoline(startFunction: eval)
////    return retVal
////}
////
////func trampoline(startFunction: SchemeContinuationFunction) {
////    var nextCont: SchemeContinuationFunction? = startFunction
////
////    continuationStack.push(object: nil)
////    while nextCont != nil {
////        //force unwrap -> Bin mir sicher dass es nicht nil ist.
////        nextCont = nextCont!.function()
////    }
////}
//
//// CALLER:
//// Push(expression)
//// Push(environment)
//// Aufruf trampoline
//fileprivate let C_eval = SchemeContinuationFunction(function: {
//    // expects on eval stack: expression and environment
//    guard let environment: SchemeEnvironment = evalStack.pop().environmentObject() else {
//        ERROR(message: "This should never happen 1")
//        return nil
//    }
//    let expression: Object = evalStack.pop()
//    
//    switch expression {
//    case .Symbol(let symbol):
//        guard let knownValue = environment.get(key: symbol) else {
//            ERROR(message: "This should never happen 2")
//            return nil
//        }
//        retVal = knownValue
//        return continuationStack.pop()
//    case .Cons(_):
//        evalStack.push(object: expression)
//        evalStack.push(object: Object.Environment(value: environment))
//        return evalList
//    default:
//        retVal = expression
//        return continuationStack.pop()
//    }
//})
//
//fileprivate let evalList = SchemeContinuationFunction(function: {
//    // expects on eval stack: expression and environment
//    guard let environment: SchemeEnvironment = evalStack.pop().environmentObject(),
//          let expression: SchemeCons = evalStack.pop().consObject() else {
//        ERROR(message: "This should never happen.")
//        return nil
//    }
//    // stack should be empty now
//    let restArgs = expression.cdr
//    
//    // local variable
//    // Muss hier gepusht werden, weil die eval funktion die unteren vom Stack holen wird!
//    evalStack.push(object: Object.Environment(value: environment))
//    evalStack.push(object: restArgs)
//    // scm eval args -> Vielleicht in Function Definition mit rein
//    evalStack.push(object: expression.car)
//    evalStack.push(object: Object.Environment(value: environment))
//  
//    continuationStack.push(object: evalList_cont_1)
//    
//    return C_eval
//})
//
//fileprivate let evalList_cont_1 = SchemeContinuationFunction(function: {
//    let funcOrSyntax = retVal //Dort wird das Objekt übergebn -> Siehe eval default case
//    
//    // preserved locals werden wieder heruntergeholt
//    var restArgs = evalStack.pop()
//    guard let environment = evalStack.pop().environmentObject() else {
//        ERROR(message: "This should neve happen. It have to be an environment")
//        return nil
//    }
//    
//    // Stack ist wieder sauber
//    switch funcOrSyntax {
//    case .Syntax(let syntaxObject):
//        evalStack.push(object: funcOrSyntax)
//        evalStack.push(object: restArgs)
//        evalStack.push(object: Object.Environment(value: environment))
//        return evalSyntax
//    case .BuiltInFunction(_), .UserDefinedFunction(_):
//        LOG("FUNCTION")
//        evalStack.push(object: funcOrSyntax)
//        // first Arg Index wird gepusht
//        evalStack.push(object: .Integer(value: evalStack.currentPointer))
//        
//        // FUNKTIONIERT DAS?
//        if restArgs != .Null {
//            guard let restArgsList = restArgs.consObject() else {
//                ERROR(message: "This should never happen 4")
//                return nil
//            }
//            let nextArg = restArgsList.car
//            evalStack.push(object: restArgs)
//            evalStack.push(object: .Environment(value: environment))
//            
//            evalStack.push(object: nextArg)
//            evalStack.push(object: .Environment(value: environment))
//            
//            continuationStack.push(object: evalList_cont_2)
//
//            // So werden erst alle Args evaluiert
//            return C_eval
//        }
//        // wenn das fertig ist, soll es mit cont_3 weitergehen
//        return evalList_cont_3
//    default:
//        ERROR(message: "The car of the cons is not a function or syntax, Not valid!")
//        return nil
//    }
//})
//
//fileprivate let evalList_cont_2 = SchemeContinuationFunction(function: {
//    guard let environment = evalStack.pop().environmentObject() else {
//        ERROR(message: "This should never happen 1")
//        return nil
//    }
//    guard var restArgsList = evalStack.pop().consObject() else {
//        ERROR(message: "This should never happen 1")
//        return nil
//    }
//    guard let firstArgIndex = evalStack.pop().intValue() else {
//        ERROR(message: "Integer nicht gefunden. Das sollte nicht passieren")
//        return nil
//    }
//    let nextEvaluatedArg = retVal
//    
//    evalStack.push(object: nextEvaluatedArg)
//    evalStack.push(object: .Integer(value: firstArgIndex))
//    
//    let restArgs = restArgsList.cdr
//    
//    if restArgs != .Null {
//        guard var restArgsList = restArgs.consObject() else {
//            ERROR(message: "This should never happen 1")
//            return nil
//        }
//        let nextArg = restArgsList.car
//        evalStack.push(object: restArgs)
//        evalStack.push(object: .Environment(value: environment))
//        
//        evalStack.push(object: nextArg)
//        evalStack.push(object: .Environment(value: environment))
//        
//        helperToPushEvalListCont2()
//
//        // So werden erst alle Args evaluiert
//        return C_eval
//    }
//    
//    return evalList_cont_3
//})
//
//fileprivate func helperToPushEvalListCont2() -> Void {
//    continuationStack.push(object: evalList_cont_2)
//}
//
//fileprivate let evalList_cont_3 = SchemeContinuationFunction(function: {
//    guard let firstArgIndex = evalStack.pop().intValue() else {
//        ERROR(message: "This should never happen")
//        return nil
//    }
//    let function = evalStack.get(index: firstArgIndex - 1)
//    
//    switch function {
//    case .BuiltInFunction(let value):
//        retVal = value.function(firstArgIndex, evalStack)
//        // Pop Function from evalStack
//        _ = evalStack.pop()
//        return continuationStack.pop()
//    case .UserDefinedFunction(let value):
//        // user defined function with lambda arg & bodylist
//        // definition:
//        //      (lambda (a b c) (body list))
//        //
//        // call:
//        //      on stack evaluated args
//        let functionEnvironment = SchemeEnvironment(parentEnvironment: value.homeEnvironment)
//        // a b
//        var argListName = value.argList
//        // 123 3
//        let argListValue = evalStack.getObjects(from: firstArgIndex)
//        
//        for value in argListValue {
//            guard let name = argListName.car.symbolObject() else {
//                ERROR(message: "There went something wrong")
//                return nil
//            }
//            if argListName.cdr != .Null {
//                argListName = argListName.cdr.consObject()! // Nicht swifty...
//            }
//            
//            functionEnvironment.insertOrUpdate(key: name, value: value)
//        }
//        
//        if argListName.cdr != .Null {
//            ERROR(message: "not enough arguments to function")
//        }
//        // Pop Function from evalStack
//        _ = evalStack.pop()
//        
//        let bodyList = value.bodyList
//        
//        if bodyList.car != .Null {
//            let nextBodyExpression = bodyList.car
//            
//            if bodyList.cdr == .Null {
//                // last expression in bodylist
//                // --> tailcall
//                evalStack.push(object: nextBodyExpression)
//                evalStack.push(object: .Environment(value: functionEnvironment))
//                return C_eval
//            }
//            
//            // preserve functionsEnv and restBodyList
//            // (needed in C_evalList_cont4)
//            evalStack.push(object: .Environment(value: functionEnvironment))
//            evalStack.push(object: .Cons(value: bodyList))
//            
//            // args for scm_eval
//            evalStack.push(object: nextBodyExpression)
//            evalStack.push(object: .Environment(value: functionEnvironment))
//
//            continuationStack.push(object: evalList_cont_4)
//            return C_eval
//            
//        }
//    
//        // only arrive here for an empty body
//        // (which is actually not allowd, and should
//        //  trigger an error in lambda/defined)
//        retVal = .Error(message: "Insert messge here")
//        return continuationStack.pop()
//        
//    default:
//        ERROR(message: "It's not a function, which should not happen!")
//        return nil
//    }
//})
//
//fileprivate let evalList_cont_4 = SchemeContinuationFunction(function: {
//    let lastValue = retVal
//    guard var restBodyList = evalStack.pop().consObject(),
//          let functionsEnvironment = evalStack.pop().environmentObject() else {
//        ERROR(message: "This should never happen!")
//        return nil
//    }
//    
//    let restBody = restBodyList.cdr
//    if restBody == .Null {
//        // never reached, because we always look ahead
//        // to see if about to evaluate the last expression
//        // (see --> tailcall above and in C_evalList_cont3)
//        return continuationStack.pop()
//    }
//    
//    guard var restBodyList2 = restBody.consObject() else {
//        ERROR(message: "This should never happen 1")
//        return nil
//    }
//    let nextBodyExpression = restBodyList2.car
//
//    if restBodyList2.cdr == .Null {
//        // last expression in bodylist
//        // --> tailcall
//        evalStack.push(object: nextBodyExpression)
//        evalStack.push(object: .Environment(value: functionsEnvironment))
//        return C_eval
//    }
//
//    // preserve environment and bodyList for cont4
//    evalStack.push(object: .Environment(value: functionsEnvironment))
//    evalStack.push(object: restBody)
//    
//    evalStack.push(object: nextBodyExpression)
//    evalStack.push(object: .Environment(value: functionsEnvironment))
//    
//    helperToPushEvalListCont4()
//    return C_eval
//})
//
//fileprivate func helperToPushEvalListCont4() -> Void {
//    continuationStack.push(object: evalList_cont_4)
//}
//
//fileprivate let evalSyntax = SchemeContinuationFunction(function: {
//    LOG("SYNTAX")
//    guard let environment = evalStack.pop().environmentObject(),
//        let argList = evalStack.pop().consObject(),
//        let syntaxObject = evalStack.pop().syntaxObject() else {
//        ERROR(message: "This should never happen 1")
//        return nil
//    }
//    
//    switch syntaxObject.type {
//    case .Define: return evalDefineSyntax(define: syntaxObject, in: environment, with: argList)
//    case .Begin: return evalBeginSyntax(begin: syntaxObject, in: environment, with: argList)
//    case .If: return evalIfSyntax(if: syntaxObject, in: environment, with: argList)
//    case .Set: return evalSetSyntax(set: syntaxObject, in: environment, with: argList)
//    case .Lambada: return evalLambdaSyntax(lambda: syntaxObject, in: environment, with: argList)
//    case .Quote: return evalQuoteSyntax(quote: syntaxObject, in: environment, with: argList)
//    }
//})
//fileprivate func evalBeginSyntax(begin: SchemeSyntax, in environment: SchemeEnvironment, with args: SchemeCons) -> SchemeContinuationFunction? {
//    // TEACH ME HOW TO DO THIS
//    return nil
//}
//
//fileprivate func evalIfSyntax(if: SchemeSyntax, in environment: SchemeEnvironment, with args: SchemeCons) -> SchemeContinuationFunction? {
//    let unevaluatedCond = args.car
//    guard let trueExpr = args.cdr.consObject()?.car,
//          let falseExpr = args.cdr.consObject()?.cdr.consObject()?.car else {
//        ERROR(message: "(if): 3 args expected");
//        return nil
//    }
//    if unevaluatedCond == .Null || trueExpr == .Null || falseExpr == .Null {
//        ERROR(message: "(if): 3 args expected");
//        return nil
//    }
//    
//    // for continuation
//    evalStack.push(object: .Environment(value: environment))
//    evalStack.push(object: trueExpr)
//    evalStack.push(object: falseExpr)
//
//    // eval the condition
//    evalStack.push(object: unevaluatedCond)
//    evalStack.push(object: .Environment(value: environment))
//    
//    continuationStack.push(object: if_cont_1)
//    return C_eval
//}
//
//fileprivate func evalSetSyntax(set: SchemeSyntax, in environment: SchemeEnvironment, with args: SchemeCons) -> SchemeContinuationFunction? {
//    guard let varName = args.car.symbolObject(),
//          let restArgs = args.cdr.consObject(),
//          let unevaluatedVarValue = args.cdr.consObject()?.car else {
//            ERROR(message: "(set!): 2 args expected")
//            return nil
//    }
//    
//    if restArgs.cdr != .Null {
//        ERROR(message: "(set!): only 2 args expected")
//        return nil
//    }
//    // for continuation
//    evalStack.push(object: .Symbol(value: varName))
//    evalStack.push(object: .Environment(value: environment))
//    
//    // to eval
//    evalStack.push(object: unevaluatedVarValue)
//    evalStack.push(object: .Environment(value: environment))
//
//    continuationStack.push(object: set_cont_1)
//    return C_eval
//}
//
//fileprivate func evalLambdaSyntax(lambda: SchemeSyntax, in environment: SchemeEnvironment, with args: SchemeCons) -> SchemeContinuationFunction? {
//    guard let argList = args.car.consObject() else {
//        ERROR(message: "Args erwartet")
//        return nil
//    }
//    guard let bodyList = args.cdr.consObject() else {
//        ERROR(message: "Mindestend 2 args erwartet")
//        return nil
//    }
//    
//    retVal = .UserDefinedFunction(value: .init(homeEnvironment: environment, argList: argList, bodyList: bodyList))
//    
//    return continuationStack.pop()
//}
//
//fileprivate func evalQuoteSyntax(quote: SchemeSyntax, in environment: SchemeEnvironment, with args: SchemeCons) -> SchemeContinuationFunction? {
//    if args.car == .Null {
//        ERROR(message: "(Quote): 1 arg erwartet")
//        return nil
//    }
//    
//    if args.cdr != .Null {
//        ERROR(message: "(Quote): genau 1 arg erwartet")
//        return nil
//    }
//    
//    retVal = args.car
//    return continuationStack.pop()
//}
//
//fileprivate func evalDefineSyntax(define: SchemeSyntax, in environment: SchemeEnvironment, with args: SchemeCons) -> SchemeContinuationFunction? {
//    // (define varname 123)
//    //         _ ___  varvalue
//    // OR
//    // (define (funcname var var) (+ var var))
//    //          -------  arglist   bodylist
//    let varOrFunc = args.car
//    
//    if let varName = varOrFunc.symbolObject() {
//        // simple define (define var expr)
//        guard let restArg = args.cdr.consObject() else {
//            ERROR(message: "(define): 2 args expected")
//            return nil
//        }
//        
//        if restArg.cdr != .Null {
//            ERROR(message: "(define): only 2 args expected")
//            return nil
//        }
//        
//        // preserve for c_define 2
//        evalStack.push(object: .Symbol(value: varName))
//        evalStack.push(object: .Environment(value: environment))
//        
//        // evaluate the args before cdefine is called
//        evalStack.push(object: restArg.car) // restArg.car = unevaluatedVarValue
//        evalStack.push(object: .Environment(value: environment))
//
//        continuationStack.push(object: define_cont_1)
//        
//        return C_eval
//        
//    } else {
//        // (define (funcname var var) (+ var var)) -> shorthand lambda
//        //          -------  arglist   bodylist
//        guard let cons = varOrFunc.consObject() else {
//            ERROR(message: "Bad arg. Es sollte ein Cons Objekt sein")
//            return nil
//        }
//        
//        guard let funcName = cons.car.symbolObject() else {
//            ERROR(message: "Bad function name. Es sollte ein Symbol Objekt sein")
//            return nil
//        }
//        
//        guard let argList = cons.cdr.consObject() else {
//            ERROR(message: "Bad arg name list")
//            return nil
//        }
//        
//        if !isValidFormalArgList(args: argList) {
//            ERROR(message: "Bad arg name list")
//            return nil
//        }
//        
//        // (+ var var)
//        guard let bodyList = args.cdr.consObject() else {
//            ERROR(message: "Body List is no cons")
//            return nil
//        }
//        
//        let function = Object.UserDefinedFunction(value: .init(homeEnvironment: environment, argList: argList, bodyList: bodyList))
//        environment.insertOrUpdate(key: funcName, value: function)
//        retVal = .Void
//        return continuationStack.pop()
//    }
//}
//
//fileprivate func isValidFormalArgList(args: SchemeCons) -> Bool {
//    if args.car.symbolObject() == nil {
//        return false
//    }
//    if let restArgs = args.cdr.consObject() {
//        return isValidFormalArgList(args: restArgs)
//    }
//    return true
//}
//
//
//fileprivate let define_cont_1 = SchemeContinuationFunction(function: {
//    let varValue = retVal
//    
//    guard let environment = evalStack.pop().environmentObject(),
//          let varName = evalStack.pop().symbolObject() else {
//        ERROR(message: "This should never happen 6")
//        return nil
//    }
//    
//    environment.insertOrUpdate(key: varName, value: varValue)
//    
//    retVal = .Void
//    
//  return nil
//})
//
//fileprivate let if_cont_1 = SchemeContinuationFunction(function: {
//    let condition = retVal
//    let falseExpr = evalStack.pop()
//    let trueExpr = evalStack.pop()
//    guard let environment = evalStack.pop().environmentObject() else {
//        ERROR(message: "This should never happen 7")
//        return nil
//    }
//    
//    switch condition {
//    case .True:
//        evalStack.push(object: trueExpr)
//        evalStack.push(object: .Environment(value: environment))
//    case .False:
//        evalStack.push(object: falseExpr)
//        evalStack.push(object: .Environment(value: environment))
//    default:
//        ERROR(message: "non binary condition");
//        return nil
//    }
//    return C_eval
//})
//
//fileprivate let set_cont_1 = SchemeContinuationFunction(function: {
//    let varValue = retVal
//    guard let environment = evalStack.pop().environmentObject(),
//          let varName = evalStack.pop().symbolObject()  else {
//        ERROR(message: "This should never happen 1")
//        return nil }
//    
//    environment.insertOrUpdate(key: varName, value: varValue)
//    
//    retVal = .Void
//    return continuationStack.pop()
//})
//
//
//
//
//
//
//
////// layer 4
////private func plus(firstArgIndex: Int) -> Object {
////    let args = evalStack.getObjects(from: firstArgIndex)
////    var sum = 0
////    for integer in args {
////        guard let value = integer.intValue() else { return .Error }// Throw an error}
////        sum = sum + value
////    }
////    return .Integer(value: sum)
////}
////
////private func minus(firstArgIndex: Int) -> Object {
////    var args = evalStack.getObjects(from: firstArgIndex)
////    if !(args.count > 1) {
////        ERROR(message: "- mindestens einen Wert")
////        return .Error
////    }
////    guard let firstInt = args.removeFirst().intValue() else {
////        ERROR(message: "- braucht einen IntValue")
////        return .Error
////    }
////    
////    if args.count == 0 {
////        return .Integer(value: -firstInt)
////    }
////
////    var retVal = firstInt
////    for object in args {
////        guard let int = object.intValue() else {
////            ERROR(message: "- braucht einen IntValue")
////            return .Error
////        }
////        retVal = retVal - int
////    }
////    return .Integer(value: retVal)
////}
////
////private func times(firstArgIndex: Int) -> Object {
////    let args = evalStack.getObjects(from: firstArgIndex)
////    var product = 1
////    for integer in args {
////        guard let value = integer.intValue() else {
////            ERROR(message: "Times - only Integer values")
////            return .Error
////        }// Throw an error}
////        product = product * value
////    }
////    return .Integer(value: product)
////}
////
////private func eq(firstArgIndex: Int) -> Object {
////    let args = evalStack.getObjects(from: firstArgIndex)
////    if args.count != 2 {
////        ERROR(message: "EQ braucht 2 vergleichbare Werte")
////        return .Error
////    }
////    return args[0] === args[1] ? .True : .False
////}
////
////private func eqnr(firstArgIndex: Int) -> Object {
////    let args = evalStack.getObjects(from: firstArgIndex)
////    if args.count != 2 {
////        ERROR(message: "= braucht 2 vergleichbare Werte")
////        return .Error
////    }
////    guard let firstInt = args[0].intValue(),
////          let secondInt = args[1].intValue() else {
////        ERROR(message: "= kann nur Integer vergleichen")
////        return .Error
////    }
////    return firstInt == secondInt ? .True : .False
////}
////
////private func gtnr(firstArgIndex: Int) -> Object {
////    let args = evalStack.getObjects(from: firstArgIndex)
////    if args.count != 2 {
////        ERROR(message: "> braucht 2 vergleichbare Werte")
////        return .Error
////    }
////    guard let firstInt = args[0].intValue(),
////          let secondInt = args[1].intValue() else {
////        ERROR(message: "> kann nur Integer vergleichen")
////        return .Error
////    }
////    return firstInt > secondInt ? .True : .False
////}
////
////private func stnr(firstArgIndex: Int) -> Object {
////    let args = evalStack.getObjects(from: firstArgIndex)
////    if args.count != 2 {
////        ERROR(message: "< braucht 2 vergleichbare Werte")
////        return .Error
////    }
////    guard let firstInt = args[0].intValue(),
////          let secondInt = args[1].intValue() else {
////        ERROR(message: "< kann nur Integer vergleichen")
////        return .Error
////    }
////    return firstInt < secondInt ? .True : .False
////}
////
////private func cons(firstArgIndex: Int) -> Object {
////    let args = evalStack.getObjects(from: firstArgIndex)
////    if args.count != 2 {
////        ERROR(message: "cons braucht 2 Werte")
////        return .Error
////    }
////    
////    return .Cons(value: .init(car: args[0], cdr: args[1]))
////}
////
////private func car(firstArgIndex: Int) -> Object {
////    let args = evalStack.getObjects(from: firstArgIndex)
////    if args.count != 1 {
////        ERROR(message: "car braucht 1 Wert")
////        return .Error
////    }
////    guard let cons = args[0].consObject() else {
////        ERROR(message: "kein Cons Objekt")
////        return .Error
////    }
////    
////    return cons.car
////}
////
////private func cdr(firstArgIndex: Int) -> Object {
////    let args = evalStack.getObjects(from: firstArgIndex)
////    if args.count != 1 {
////        ERROR(message: "cdr braucht 1 Wert")
////        return .Error
////    }
////    guard let cons = args[0].consObject() else {
////        ERROR(message: "kein Cons Objekt")
////        return .Error
////    }
////    
////    return cons.cdr
////}
////
//////public func eval(firstArgIndex: Int) -> Object {
//////    let args = evalStack.getObjects(from: firstArgIndex)
//////    if args.count != 1 {
//////        ERROR(message: "eval braucht 1 funktion")
//////        return .Error
//////    }
//////    return eval(expression: args[0], environment: globalEnvironment)
//////}
////
////private func display(firstArgIndex: Int) -> Object {
////    let args = evalStack.getObjects(from: firstArgIndex)
////    args.forEach { (object) in
////        printer.display(object: object)
////    }
////    return .Void
////}
////
////
//
//
//
//
//
//
//
//
//
//
//
////GrundIdee:
////
////f1() {
////    ...
////    f2(cont1)
////    cont 1 -> f2 mitgeben, dass wenn du fertig bist, bitte bei cont1 weiter machen.
////    ...
////}
////
////f2(continuation id) {
////    ...
////    f3()
////    ...
////    return == goto continuation
////}
////
////Wir müssen uns merken wo der return hingehen muss!
////
////
////Variante 2
////
////
////2.Stack:
////ReturnStack (analog zu object stack)
////rPUSH
////rPOP
////
////f1() {
////    ...
////    push(cont1) Auf eigenen stack
////    f2()
////    cont 1
////    ...
////}
////
////f2() {
////    ...
////    f3()
////    ...
////    continuation = rPop()
////    return == goto continuation
////}
////
////
////trampoline(startCont) {
////    nextCont = startCont;
////
////    while(nextCont != 0) {
////        nextCont = (nextCont)() // continuation pointer soll zurückkommen
////    }
////}
////
////
////
////
////TailCall:
////
////trampoline (t_f1)
////
////f1() {
////    ...
////    return f2();
////}
////
////f2() {
////    ...
////    return x;
////}
////
////t_f1() {
////    ...
////    rPush(cont1)
////    return t_f2
////}
////
////cont1() {
////    c = rPOP()
////    return c;
////}
////
////t_f2() {
////    ...
////    c = rPOP()
////    return c;
////}
////
//
////
////private let trampoline_f1 = SchemeContinuationFunction(function: {
////    LOG("Start f1")
////    T_Evaluator.continuationStack.push(object: trampoline_cont_f1)
////    return trampoline_f2
////})
////
////private let trampoline_cont_f1 = SchemeContinuationFunction(function: {
////    LOG("Cont f1")
////    return T_Evaluator.continuationStack.pop()
////})
////
////private let trampoline_f2 = SchemeContinuationFunction(function: {
////    LOG("Start f2")
////    T_Evaluator.continuationStack.push(object: trampoline_cont_f2)
////
////    return trampoline_f3
////})
////
////private let trampoline_cont_f2 = SchemeContinuationFunction(function: {
////    LOG("Cont f2")
////    return trampoline_f4
////})
////
////private let trampoline_f4 = SchemeContinuationFunction(function: {
////    LOG("Start f4")
////    return T_Evaluator.continuationStack.pop()
////})
////
////private let trampoline_f3 = SchemeContinuationFunction(function: {
////    LOG("Start f3")
////    return T_Evaluator.continuationStack.pop()
////})
////
//
