//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Bryan Ye on 12/05/2016.
//  Copyright © 2016 Bryan Ye. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    var description = ""
    
    var isPartialResult: Bool {
        return pending != nil
    }
    
    private var accumulator = 0.0
    
    private var internalProgram = [AnyObject]()
    
    private var ops: [String:Op] = [
        "π" : Op.Constant(M_PI),
        "e" : Op.Constant(M_E),
        "√" : Op.UnaryOperation(sqrt),
        "sin" : Op.UnaryOperation(sin),
        "cos" : Op.UnaryOperation(cos),
        "tan" : Op.UnaryOperation(tan),
        "ln" : Op.UnaryOperation(log),
        "log" : Op.UnaryOperation(log10),
        "±" : Op.UnaryOperation({-$0}),
        "✕" : Op.BinaryOperation({$0 * $1}),
        "÷" : Op.BinaryOperation({$1 / $0}),
        "+" : Op.BinaryOperation({$0 + $1}),
        "-" : Op.BinaryOperation({$1 - $0}),
        "=" : Op.isEquals,
        ]
    
    private enum Op {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double,Double) -> Double)
        case isEquals
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        if symbol == "√" {
            if isPartialResult {
                let removeLastCharFromDescription = String(description.characters.dropLast())
                description = removeLastCharFromDescription + "√(" + String(accumulator) + ")"
            } else {
                description = "√(" + description + ")"
            }
        } else if symbol != "=" {
            description = description + symbol
        }
        
        if let operation = ops[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .isEquals:
                executePendingBinaryOperation()
            }
        }
    }
    
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    func appendOp(op: String) {
        description += op
    }
    
    func clearAll() {
        pending = nil
        description = ""
        accumulator = 0.0
        internalProgram.removeAll()
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            clearAll()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand)
    }
    
    func setOperand(variableName: String) {
        if pending == nil {
            clearAll()
        }
        accumulator = variableValues[variableName] ?? 0
        internalProgram.append(variableName)
        
    }
    
    var variableValues = [String: Double]() {
        didSet {
            program = internalProgram
        }
    }
    
    func undo() -> Double? {
        var undoValue: Double? = nil
        if internalProgram.count > 0 {
            internalProgram.removeLast()
            if internalProgram.last as? Double != nil {
                undoValue = internalProgram.removeLast() as? Double
            }
            program = internalProgram
        }
        return undoValue
    }
    var result: Double {
            return accumulator
    }
    
}