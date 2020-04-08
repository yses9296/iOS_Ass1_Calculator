//
//  ViewController.swift
//  EunseoChoi_13340260_a1
//
//  Created by 최은서 on 2020/04/08.
//  Copyright © 2020 Eunseo Choi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var history: UILabel!
    
    let maxNumButton = 9;
    var previousNum: Double = 0;
    var numbersOnScreen: Int = 0;
    var decimal: Int = 0;
    var expressionArray: [String] = []
    var operation = 0;
    var performingMath: Bool = false;
    
    //Numbers

    @IBAction func num0(_ sender: Any) { resultChange(0) }
    @IBAction func number1(_ sender: Any) { resultChange(1) }
    @IBAction func num2(_ sender: Any) { resultChange(2) }
    @IBAction func num3(_ sender: Any) { resultChange(3) }
    @IBAction func num4(_ sender: Any) { resultChange(4) }
    @IBAction func num5(_ sender: Any) { resultChange(5) }
    @IBAction func num6(_ sender: Any) { resultChange(6) }
    @IBAction func num7(_ sender: Any) { resultChange(7) }
    @IBAction func num8(_ sender: Any) { resultChange(8) }
    @IBAction func num9(_ sender: Any) { resultChange(9) }
    

    //Functions
    @IBAction func add(_ sender: Any) { whenSelectedOperator(1) }
    @IBAction func subtract(_ sender: Any) { whenSelectedOperator(2) }
    @IBAction func multiply(_ sender: Any) { whenSelectedOperator(3) }
    @IBAction func divide(_ sender: Any) { whenSelectedOperator(4) }
    @IBAction func percent(_ sender: Any) { whenSelectedOperator(5)}
    @IBAction func firstBracket(_ sender: Any) { whenSelectedOperator(6) }
    @IBAction func secondBracket(_ sender: Any) {
        expressionArray.append(removeE(num: String(removeZero(num: previousNum))))
        expressionArray.append(")")
    }
    @IBAction func dot(_ sender: Any) {
        if !performingMath {
            performingMath = true
            numbersOnScreen += 1
            self.result.text = removeZero(num: previousNum) + "."
        }
    }
    
    @IBAction func reset(_ sender: Any) {
        previousNum = 0
        howManyInit()
        expressionArray.removeAll()
        self.history.text = ""
        self.result.text = "0"
    }
    
    //-MARK: Numbers input
    func resultChange(_ newNum: Double) {
        guard decimal + numbersOnScreen < maxNumButton else {
            return
        }
        
        var fraction = newNum
        var powTen = 1
        
        if numbersOnScreen > 0 {
            for _ in 0..<numbersOnScreen {
                fraction *= 0.1
                powTen *= 10
                fraction = round(fraction * Double(powTen)) / Double(powTen)
            }
            previousNum += fraction
            previousNum = round(previousNum * Double(powTen)) / Double(powTen)
            numbersOnScreen += 1
        }
        else {
            decimal += 1
            previousNum = previousNum * 10 + newNum
        }
        self.result.text = removeZero(num: previousNum)
    }
    
    @IBAction func printResult(_ sender: Any) {
        if expressionArray.last != ")"{
            expressionArray.append(removeE(num: String(removeZero(num: previousNum))))
        }
        self.history.text = expressionArray.joined(separator: " ")
        expressionArray.append("\n")
        
        getBracketValue(num: -1)
        getValue(num: -1, lastCh: "\n")
        
        operation = 0
        previousNum = Double(expressionArray.first!)!
        expressionArray.removeAll()
        howManyInit()
    }
    
    //-MARK: Functions
    func getValue(num: Int, lastCh: String){
        var i = num
        var insertNum: Double = 0
        
        repeat {
            i += 1
            switch expressionArray[i] {
            case "+" :
                insertNum = operateTwoNum(Double(expressionArray[i-1])!, Double(expressionArray[i+1])!, operation: operateAdd)
                for _ in 0..<3 { expressionArray.remove(at: i-1) }
                expressionArray.insert(String(insertNum), at: i-1)
                i -= 1
            case "-" :
                insertNum = operateTwoNum(Double(expressionArray[i-1])!, Double(expressionArray[i+1])!, operation: operateSubtract)
                for _ in 0..<3 { expressionArray.remove(at: i-1) }
                expressionArray.insert(String(insertNum), at: i-1)
                i -= 1
            case "*" :
                insertNum = operateTwoNum(Double(expressionArray[i-1])!, Double(expressionArray[i+1])!, operation: operateMultiply)
                for _ in 0..<3 { expressionArray.remove(at: i-1) }
                expressionArray.insert(String(insertNum), at: i-1)
                i -= 1
            case "/" :
                    insertNum = operateTwoNum(Double(expressionArray[i-1])!, Double(expressionArray[i+1])!, operation: operateDivide)
                for _ in 0..<3 { expressionArray.remove(at: i-1) }
                expressionArray.insert(String(insertNum), at: i-1)
                i -= 1
            case "%" :
                insertNum = operateTwoNum(Double(expressionArray[i-1])!, Double(expressionArray[i+1])!, operation: operatePercent)
                for _ in 0..<3 { expressionArray.remove(at: i-1) }
                expressionArray.insert(String(insertNum), at: i-1)
                i -= 1
                
            default:
                break
            }
        }while expressionArray[i] != lastCh
    }
    
    func whenSelectedOperator(_ num:Int) {
        if expressionArray.last != ")" && num != 6 || expressionArray.isEmpty && previousNum != 0 {
            expressionArray.append(removeE(num: String(removeZero(num:previousNum))))
        }
        switch num{
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
            if let test = expressionArray.last {
                if test != "+" && test != "-" && test != "*"  && test != "/" && test != "%" {
                    expressionArray.append("*")
                }
            }
            expressionArray.append("(")
        default:
            break
        }
        self.history.text = expressionArray.joined(separator: " ")
        operation = num
        previousNum = 0
        howManyInit()
    }
    
    var operateAdd: (Double, Double) -> Double = { $0 + $1 }
    var operateSubtract: (Double, Double) -> Double = { $0 - $1 }
    var operateMultiply: (Double, Double) -> Double = { $0 * $1 }
    var operateDivide: (Double, Double) -> Double = { $0 / $1 }
    var operatePercent: (Double, Double) -> Double = { $0.truncatingRemainder(dividingBy: $1) }
    
    func operateTwoNum(_ a: Double, _ b: Double, operation: (Double, Double) -> Double) -> Double {
        previousNum = round(operation(a, b) * 1000000000000000) / 1000000000000000
        self.result.text = removeZero(num: previousNum) //delete under including 0
        return previousNum
    }
    //Bracket function
    func getBracketValue(num: Int){
        var i = num
        repeat {
                i += 1
            switch expressionArray[i]{
            case "(" :
                if !expressionArray.contains(")"){
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
    // -MARK: Delete decimal under 0 and log e
    func removeZero(num: Double) -> String {
        let formatString = "%." + String(numbersOnScreen-1) + "f"
        let floatNumString = num == floor(num) ? String(format: formatString, num) : String(num)
        return removeE(num: floatNumString)
    }
    
    func removeE(num: String) -> String {
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
            for _ in 0..<Int(sub)!-1 {result.append("0.")}
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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

