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
    
    var isPartialResult = false
    
    private var accumulator = 0.0
    
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
                isPartialResult = true
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .isEquals:
                isPartialResult = false
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
        isPartialResult = false
        accumulator = 0.0
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
}