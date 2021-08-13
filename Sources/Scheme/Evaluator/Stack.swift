//
//  Stack.swift
//  Scheme
//
//  Created by Niklas Schildhauer on 02.08.21.
//

import Foundation

//  MARK: Implementation Stack
/// This class is used as a eval stack. The evaluator uses the stack to push objects onto it,
/// which than can later be retrieved by the functions that need them.
class Stack<T> {
    /// The stack is using an array to store the elements
    private var stack: [T] = []
    /// The pointer points on the newest inserted object.
    private var pointer: Int = 0
    var currentPointer: Int {
        get {
            pointer
        }
        set {
            pointer = newValue
        }
    }
    
    /// This function pushes a new object onto the stack
    func push(object: T) {
        if stack.count <= self.pointer {
            self.stack.append(object)
        } else {
            self.stack[pointer] = object
        }
        self.pointer = pointer + 1
    }
    
    /// This function pushes many functions onto the stack
    /// It calls the push(object: T).
    func push(objects: [T]) {
        objects.forEach { object in
            self.push(object: object)
        }
    }
    
    /// This functions pops the last inserted object from the stack
    func pop() -> T {
        self.pointer = pointer - 1
        return stack[pointer]
    }
    
    /// This functions returns an object at a specific index
    func get(index: Int) -> T {
        return stack[index]
    }
    
    /// This functions returns an array of the objects between the index in the arguments
    /// and the actual pointer.
    func getObjects(from index: Int) -> [T] {
        let retVal = Array(stack[index ..< currentPointer])
        self.pointer = index
        return retVal
    }
    
    /// This function clears the whole stack and removes all elements.
    func clearStack() -> Void {
        pointer = 0
        self.stack = []
    }
}
