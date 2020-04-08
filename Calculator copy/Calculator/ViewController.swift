//
//  ViewController.swift
//  Calculator
//
//  Created by 최은서 on 2020/04/03.
//  Copyright © 2020 Eunseo Choi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let maxNumButton = 9;
    var numbersOnScreen:Int = 0;
    var previousNumber:Double = 0;
    var performingMath:Bool = false;
    var operation = 0;
    var decimal: Int = 0;
    var expressionArray: [String] = [];
    
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var history: UILabel!
    
    func resultChange(_ newNum: Double){
        guard decimal + numbersOnScreen < maxNumButton else{ return }
        
        var fraction = newNum
        var powTen = 1
        
        if numbersOnScreen > 0{
            for _ in 0..<numbersOnScreen {
                fraction *= 0.1
                powTen *= 10
                fraction = round(fraction * Double(powTen))
            }
            previousNumber += fraction
            previousNumber = round(previousNumber * Double(powTen))
            numbersOnScreen += 1
        }
        else {
            decimal += 1
            previousNumber = previousNumber * 10 + newNum
        }
        self.result.text = removeZero(num: previousNumber)
    }
    
    @IBAction func num0(_ sender: Any) {resultChange(0)}
    @IBAction func num1(_ sender: Any) {resultChange(1)}
    @IBAction func num2(_ sender: Any) {resultChange(2)}
    @IBAction func num3(_ sender: Any) {resultChange(3)}
    @IBAction func num4(_ sender: Any) {resultChange(4)}
    @IBAction func num5(_ sender: Any) {resultChange(5)}
    @IBAction func num6(_ sender: Any) {resultChange(6)}
    @IBAction func num7(_ sender: Any) {resultChange(7)}
    @IBAction func num8(_ sender: Any) {resultChange(8)}
    @IBAction func num9(_ sender: Any) {resultChange(9)}
    
    @IBAction func add(_ sender: Any) {whenSelectedOperator(1)}
    @IBAction func subtract(_ sender: Any) {whenSelectedOperator(2)}
    @IBAction func multiple(_ sender: Any) {whenSelectedOperator(3)}
    @IBAction func divide(_ sender: Any) {whenSelectedOperator(4)}
    @IBAction func percent(_ sender: Any) {whenSelectedOperator(5)}
    @IBAction func firstBraket(_ sender: Any) {whenSelectedOperator(6)}
    @IBAction func secondBraket(_ sender: Any) {
        expressionArray.append(removeE(num: String(removeZero(num: previousNumber))))
        expressionArray.append(")")
    }
    
    @IBAction func dot(_ sender: Any) {
        if !performingMath {
            performingMath = true
            previousNumber += 1
            self.result.text = removeZero(num: previousNumber) + "."
        }
    }
    @IBAction func clear(_ sender: Any) {
        previousNumber = 0
        howManyInit()
        expressionArray.removeAll()
        self.history.text = ""
        self.result.text = "0"
    }

    @IBAction func printResult(_ sender: Any) {
        if expressionArray.last != ")" {
            expressionArray.append(removeE(num: String(removeZero(num: previousNumber))))
        }
        self.history.text = expressionArray.joined(separator: " ")
        expressionArray.append("\n)")
        
        getBracketValue(num: -1)
        getValue(num: -1, lastCh: "\n")
    }
    
    //press the functions buttons
    func whenSelectedOperator(_ num:Int) {
        if expressionArray.last != ")" && num != 6 || expressionArray.isEmpty && previousNumber != 0 {
            expressionArray.append(removeE(num: String(removeZero(num: previousNumber))))
        }
        switch num {
        case 1:
            expressionArray.append("+")
        case 2:
            expressionArray.append("-")
        case 3:
            expressionArray.append("*")
        case 4:
            expressionArray.append("/")
        case 5:
            expressionArray.append("%")
        case 6:
            if let test = expressionArray.last{
                if test != "+" && test != "-" && test != "*" && test != "/" && test != "%" {
                    expressionArray.append("*")
                    
                }
            }
            expressionArray.append("")
            
        default:
            break
        }
        self.history.text = expressionArray.joined(separator: " ")
        operation = num
        previousNumber = 0
        howManyInit()
    }
    
    //Bracket function
    func getBracketValue(num: Int) {
        var i = num
        repeat {
            i += 1
            switch expressionArray[i] {
            case "(" :
                if !expressionArray.contains(")") {
                    expressionArray.append(")")
                }
                getValue(num: i + 1, lastCh: ")")
                expressionArray.remove(at: i)
                expressionArray.remove(at: i+1)
            default:
                break
            }
        }while expressionArray[i] != "\n"
    }
    
    //Add, Subtract, Multiple, Divide, Percent function
    func getValue(num: Int, lastCh: String){
        var i = num
        var insertNum: Double = 0
        
        repeat {
            i += 1
            switch expressionArray[i] {
            case "+" :
                insertNum = operateTwoNum(Double(expressionArray[i-1])!, Double(expressionArray[i+1])!, operation: operateAdd)
                for _ in 0..<3 { expressionArray.remove(at: i-1)}
                expressionArray.insert(String(insertNum), at: i-1)
                i -= 1
            case "-" :
                insertNum = operateTwoNum(Double(expressionArray[i-1])!, Double(expressionArray[i+1])!, operation: operateSubtract)
                for _ in 0..<3 { expressionArray.remove(at: i-1)}
                expressionArray.insert(String(insertNum), at: i-1)
                i -= 1
            case "*" :
                insertNum = operateTwoNum(Double(expressionArray[i-1])!, Double(expressionArray[i+1])!, operation: operateMultiply)
                for _ in 0..<3 { expressionArray.remove(at: i-1)}
                expressionArray.insert(String(insertNum), at: i-1)
                i -= 1
            case "/" :
                insertNum = operateTwoNum(Double(expressionArray[i-1])!, Double(expressionArray[i+1])!, operation: operateDivide)
                for _ in 0..<3 { expressionArray.remove(at: i-1)}
                expressionArray.insert(String(insertNum), at: i-1)
                i -= 1
            case "%" :
                insertNum = operateTwoNum(Double(expressionArray[i-1])!, Double(expressionArray[i+1])!, operation: operatePercentage)
                for _ in 0..<3 { expressionArray.remove(at: i-1)}
                expressionArray.insert(String(insertNum), at: i-1)
                i -= 1
                default:
                break
            }
        }
        while expressionArray[i] != lastCh
    }
    func operateTwoNum(_ a : Double, _ b: Double, operation: (Double, Double) -> Double) -> Double {
        previousNumber = round(operation(a, b) * 1000000000000000) / 1000000000000000 //cutting the deciaml under 15th
        self.result.text = removeZero(num: previousNumber) // deleted under 0
        return previousNumber
    }
    var operateAdd: (Double, Double) -> Double = { $0 + $1}
    var operateSubtract:(Double, Double) -> Double = { $0 - $1}
    var operateMultiply:(Double, Double) -> Double = { $0 * $1}
    var operateDivide:(Double, Double) -> Double = { $0 / $1}
    var operatePercentage:(Double, Double) -> Double = { $0 + $1}
    
    //delete under the decimal 0 and log
    func removeZero(num: Double) -> String {
        let formatString = "%." + String(numbersOnScreen-1) + "f"
        let floafNumString = num == floor(num) ? String(format: formatString, num) : String(num)
        return removeE(num: floafNumString)
        }
    
    func removeE(num: String) -> String{
        let a = num
        
        if a.contains("e-"){
            var temp = ""
            
            for i in 0..<a.count {
                let index = a.index(a.startIndex, offsetBy: i)
                if a[index] == "e" {break}
                if a[index] == "." {continue}
                temp.append(a[index])
            }
            
            let start = a.index(a.startIndex, offsetBy: a.count-2)
            let end = a.index(a.startIndex, offsetBy: a.count)
            let sub = a[start..<end]
            
            var result = "0."
            for _ in 0..<Int(sub)!-1 {
                result.append("0")
            }
            result.append(temp)
            return result
        }
        else {
            return String(a)
        }
    }
    
    func howManyInit(){
        decimal = 0
        numbersOnScreen = 0
        performingMath = false
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated.
    }

}
