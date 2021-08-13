//
//  SymbolTable.swift
//  Scheme
//
//  Created by Niklas Schildhauer on 21.07.21.
//

import Foundation

//  MARK: Implementation Symbol Table
/// Defines all functions which a symbol table should implement.
protocol SchemeSymbolTableProtocol {
    var size: Int { get }
    
    func getOrCreate(symbol: String)-> SchemeSymbol
}

/// This class is used to save all known symbols in a hash table. In this way each symbol is only stored once
class SymbolTable {
    /// The symbol table uses a self implemented HashTable. The Key is a string and the stored value a SchemeSymbol
    private var knownSymbols: HashTable<String, SchemeSymbol>
    /// The initial capacity of the symbol table
    private let init_symbol_table_size = 512
    
    
    //  MARK: Constructor
    init() {
        self.knownSymbols = HashTable<String, SchemeSymbol>(capacity: self.init_symbol_table_size)
    }
    
}

// MARK: Protocol Conformance
extension SymbolTable: SchemeSymbolTableProtocol {
    /// returns the count of the known symbols
    var size: Int {
        knownSymbols.size
    }
 
    /// This is the main function of the symbol table. Either it returns a known symbol for the given string
    /// or it creates and stores a new SchemeSymbol and saves it in the hash table.
    @discardableResult
    func getOrCreate(symbol: String)-> SchemeSymbol {
        if let knownSymbol = self.knownSymbols.value(for: symbol) {
            return knownSymbol
        }
        
        let newSymbol = self.knownSymbols.new(value: SchemeSymbol(value: symbol), for: symbol)
        
        // If the max capacity is reached the symbol table should grow
        if knownSymbols.size > self.fillLimit(oldCapacity: knownSymbols.maxCapacity) {
            self.grow()
        }
        return newSymbol
    }
}

private extension SymbolTable {
    
    /// To grow the table a new table will be created with a higher capacity and all the old elements will be inserted again in the new table. Afterwards the hash table will be exchanged with the new one.
    private func grow() {
        let oldElements: [SchemeSymbol] = self.knownSymbols.getAllElements()
        let newCapacity = self.growFactor(oldCapacity: self.knownSymbols.maxCapacity)
        self.knownSymbols = HashTable<String, SchemeSymbol>(capacity: newCapacity)
        
        oldElements.forEach { (element) in
            self.getOrCreate(symbol: element.characters)
        }
    }
    
    private func fillLimit(oldCapacity: Int) -> Int  {
        return oldCapacity * 3 / 4
    }
    
    private func growFactor(oldCapacity: Int) -> Int {
        return oldCapacity * 2 + 1
    }
}

