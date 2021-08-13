//
//  main.swift
//  Scheme
//
//  Created by Niklas Schildhauer on 12.08.21.
//

import Foundation

//  MARK: Main function
/// Is called as start function of the application.
/// It creates the consoleIO to read and write to the console and
/// the Scheme interpreter. In here the REPL starts.
fileprivate func main() {
    let consoleIO = ConsoleIO()
    let interpreter = Interpreter(output: consoleIO)
    
    // REPL
    while(true) {
        let input = consoleIO.getInput()
        interpreter.interpret(input: input)
    }
}

main() // Start the show

/// This class is used to print and read String on the console.
fileprivate class ConsoleIO {
    func writeToConsole(_ message: String, to output: OutputStyle = .standard) {
      switch output {
      case .standard:
        print("\(message)")
      case .result:
        print("👉🏻 \(message)")
      case .error:
        fputs("\(message)", stderr)
      case .message:
        print("\(message)")
      case .hint:
        print("\(message)")
      }
    }
        
    func getInput() -> String {
        print("") // new line
        print("👨‍💻", terminator: " ") // no break
        guard let input = readLine() else { return "" }
        return input
    }
}

//  MARK: Protocol Conformance
/// The ConsoleIO class conformance to the PrinterDelegate
/// to recieve the output strings of the interpreter.
extension ConsoleIO: PrinterDelegate {
    func didComputeOutputString(output: String, style: OutputStyle, in printer: PrinterMarkerProtocol) {
        self.writeToConsole(output, to: style)
    }
}
