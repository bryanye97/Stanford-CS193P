//
//  ViewController.swift
//  Calculator
//
//  Created by Bryan Ye on 11/05/2016.
//  Copyright © 2016 Bryan Ye. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var userIsTyping = false
    
    @IBOutlet private weak var opSequence: UILabel!
    
    @IBOutlet private weak var display: UILabel!
    
    @IBAction func clearAll(sender: UIButton) {
        brain.clearAll()
        display.text = "0"
        opSequence.text = display.text
        userIsTyping = false
        
    }
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        let textInCurrentDisplay = display.text!
        if userIsTyping {
            if digit == "." {
                if display.text!.rangeOfString(".") == nil {
                    display.text = textInCurrentDisplay + digit
                }
            } else {
                display.text = textInCurrentDisplay + digit
                
            }
        } else {
            display.text = digit
        }
        userIsTyping = true
        brain.appendOp(sender.currentTitle!)
    }
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(sender: UIButton) {

        if userIsTyping {
            brain.setOperand(displayValue)
            userIsTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        

        
        if brain.isPartialResult {
            opSequence.text = brain.description + "..."
        } else {
            opSequence.text = brain.description + "="
        }
    }
}

