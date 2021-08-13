//
//  File.swift
//  
//
//  Created by Niklas Schildhauer on 12.08.21.
//

import Foundation


print("Start the show")

let consoleIO = ConsoleIO()
let interpreter = Interpreter(output: consoleIO)

interpreter.interpret(input: "(display (fibonacci 12))")

class ConsoleIO {
    
}

extension ConsoleIO: PrinterDelegate {
    func didComputeOutputString(output: String, style: OutputStyle, in printer: PrinterMarkerProtocol) {
        print(output)
    }
}
