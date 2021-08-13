//
//  SchemeEnvironment.swift
//  
//
//  Created by Niklas Schildhauer on 23.07.21.
//

import Foundation

//  MARK: Implementation Environemnt
/// Defines all functions which a environment should implement
protocol SchemeEnvironment {
    var parentEnvironment: SchemeEnvironment? { get }
    var symbolTable: SchemeSymbolTableProtocol { get }
    
    func update(key: SchemeSymbol, value: Object) -> Bool
    func insertOrUpdate(key: SchemeSymbol, value: Object)
    func get(key: SchemeSymbol) -> Object?
}

/// This class is used to save all bindings of the environment. Therefore it also has a reference
/// to the symbol table. In this way each symbol is only created once.
class Environment {
    let parentEnvironment: SchemeEnvironment?
    let symbolTable: SchemeSymbolTableProtocol
    /// It uses a self implemented HashTable. The Key is a SchemeSymbol  and the stored value a SchemeCons
    private var bindings: HashTable<SchemeSymbol, SchemeCons>
    private let init_environment_table_size = 20
    
    //  MARK: Constructors
    /// This construcotr is used to create the home environment (top environment)
    init(symbolTable: SchemeSymbolTableProtocol) {
        self.symbolTable = symbolTable
        self.parentEnvironment = nil
        self.bindings = HashTable<SchemeSymbol, SchemeCons>(capacity: init_environment_table_size)
    }
    
    /// This construcor is used to create a functions environment
    init(parentEnvironment: SchemeEnvironment) {
        self.symbolTable = parentEnvironment.symbolTable
        self.parentEnvironment = parentEnvironment
        self.bindings = HashTable<SchemeSymbol, SchemeCons>(capacity: init_environment_table_size)
    }
}

// MARK: Protocol Conformance
extension Environment: SchemeEnvironment {
    /// Either it returns the binding object for the key or it returns nil
    func get(key: SchemeSymbol) -> Object? {
        let retVal = self.bindings.value(for: key)?.cdr
        if retVal == nil,
           let parentEnv = self.parentEnvironment {
            return parentEnv.get(key: key)
        }
        return retVal
    }

    /// This function inserts a new binding
    func insertOrUpdate(key: SchemeSymbol, value: Object) {
        // achtung hack... ich inserte einen SchemeString als car...
        let cons = SchemeCons(car: .Symbol(value: key), cdr: value)
        
        if self.bindings.value(for: key) != nil {
            self.bindings.update(value: cons, for: key)
        }
        
        self.bindings.new(value: cons, for: key)
        
        if self.bindings.size > self.fillLimit(oldCapacity: bindings.maxCapacity) {
            self.grow()
        }
    }
    
    /// This function updates the value of a known bindig.
    func update(key: SchemeSymbol, value: Object) -> Bool{
        let cons = SchemeCons(car: .Symbol(value: key), cdr: value)
        
        if self.bindings.value(for: key) == nil {
            return false
        }
        self.bindings.update(value: cons, for: key)
                
        if self.bindings.size > self.fillLimit(oldCapacity: bindings.maxCapacity) {
            self.grow()
        }
        return true
    }
}

// MARK: Helper functions
private extension Environment {
    /// If the environment reached it's max capacity. This functions creates a new hash table with
    /// a higher capacity and inserts all the old elements.
    private func grow() {
        let oldElements: [SchemeCons] = self.bindings.getAllElements()
        let newCapacity = self.growFactor(oldCapacity: self.bindings.maxCapacity)
        self.bindings = HashTable<SchemeSymbol, SchemeCons>(capacity: newCapacity)
        
        oldElements.forEach { (element) in
            self.insert(cons: element)
        }
    }

    /// Helper function to insert a SchemeCons to the hash table. The SchemeCons contains as car the key
    /// and as cdr the value of the object.
    private func insert(cons: SchemeCons) {
        guard let key = cons.car.symbolObject() else { return }
        self.insertOrUpdate(key: key, value: cons.cdr)
            
    }
    
    private func fillLimit(oldCapacity: Int) -> Int  {
        return oldCapacity * 3 / 4
    }
    
    private func growFactor(oldCapacity: Int) -> Int {
        return oldCapacity * 2 + 1
    }
}
