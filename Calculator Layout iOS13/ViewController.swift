//
//  ViewController.swift
//  Calculator Layout iOS13
//
//  Created by Angela Yu on 01/07/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {

    var isLightMode = false
    var titleLabel = PaddingLabel()
    
    var calcLabelContent = ""
    var calcLabelValue = 0
    var calcLabel = PaddingLabel()

    var answerLabelContent: String? = ""
    var answerLabelValue = 0.0
    var answerLabel = UILabel()
    
    // Labels for numbers 0, 1, ... , 9
    var numberButtons: [UIButton] = []
    
    // Labels for +, -, x, ÷, =
    var actionButtons: [String: UIButton] = [:]
    let operations = ["=", "+", "-", "x", "÷"]
    
    var specialButtons: [String: UIButton] = [:]
    var specialOperations = ["AC", "+/-", "del"]
    
    var contrastModeButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenWidth = view.safeAreaLayoutGuide.layoutFrame.width - 32
        let screenHeight = view.safeAreaLayoutGuide.layoutFrame.height - 32
        
        setTitleLabel(screenWidth, screenHeight)
        
        setCalcLabel(screenWidth, screenHeight)
        
        setAnswerLabel(screenWidth, screenHeight)

        setNumberButtons(screenWidth, screenHeight)
        
        setActionButtons(screenWidth, screenHeight)
        
        setSpecialButtons(screenWidth, screenHeight)
        
        updateContrastModeButton(screenWidth, screenHeight)
    }
    
    func updateContrastModeButton(_ screenWidth: CGFloat, _ screenHeight: CGFloat) {
        contrastModeButton.setImage(UIImage(systemName: isLightMode ? "moon.fill" : "sun.max.fill"), for: .normal)
        contrastModeButton.imageView?.tintColor = isLightMode ? .white : .black
        contrastModeButton.backgroundColor = isLightMode ? .black : .white
        contrastModeButton.layer.cornerRadius = screenHeight / 16 * 0.45
        contrastModeButton.clipsToBounds = true
        contrastModeButton.addTarget(self, action: #selector(contrastModeToggled(_:)), for: .touchUpInside)
        
        self.view.addSubview(contrastModeButton)
        setAutoConstraints(someView: contrastModeButton, width: screenHeight / 16, height: screenHeight / 16, xOffset: 0.0, yOffset: screenHeight / 32, xRelative: true, yRelative: true, xLeading: true, yTop: true)
    }
    
    func createButton(title: String, backgroundColor: UIColor) -> UIButton {
        let screenWidth = view.safeAreaLayoutGuide.layoutFrame.width - 32
        let screenHeight = view.safeAreaLayoutGuide.layoutFrame.height - 32
        
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.titleLabel!.font = UIFont(name: "AvenirNext-Bold", size: screenWidth / 10 - 5)
        button.setTitleColor(isLightMode ? UIColor.white : UIColor.black, for: .normal)
        button.layer.cornerRadius = screenHeight / 9 * 0.45
        button.clipsToBounds = true
        button.layer.borderWidth = 4
        button.layer.borderColor = isLightMode ? UIColor.white.cgColor : UIColor.black.cgColor
        return button
    }
    
    func calcAnswerDMAS(_ regex: String) -> Double {

        var values = [String]()
        var operations = [String]()
        var value = ""

        for i in regex {
            if i.isNumber || i == "." {
                value += String(i)
            }
            else {
                values.append(value)
                value = ""
                operations.append(String(i))
            }
        }
        if value != "" {
            values.append(value)
        }
        if values.count == 0 {
            return 0.0
        }
        guard values.count >= 2 else {
            return Double(values[0])!
        }

        if operations.count > values.count {
            return Double(Int.min)
        }
        
        print(values)
        for op in 0..<operations.count {
            if operations[op] == "÷" {
                if values.count == 2 {
                    return Double(values[0])! / Double(values[1])!
                }
                if op == operations.count - 1 {
                        values[op] = String(Double(values[op])! / Double(values[op+1])!)
                        values.remove(at: op+1)
                }
                else {
                    values[operations.count - op - 2] = String(Double(values[operations.count - op - 2])! / Double(values[operations.count - op - 1])!)
                    values.remove(at: operations.count - op - 1)
                }
            }
        }
        for op in 0..<operations.count {
            if operations[op] == "x" {
                if values.count == 2 {
                    return Double(values[0])! * Double(values[1])!
                }
                if op == operations.count - 1 {
                        values[op] = String(Double(values[op])! * Double(values[op+1])!)
                        values.remove(at: op+1)
                }
                else {
                    values[operations.count - op - 2] = String(Double(values[operations.count - op - 2])! * Double(values[operations.count - op - 1])!)
                    values.remove(at: operations.count - op - 1)
                }
            }
        }
        for op in 0..<operations.count {
            if operations[op] == "+" {
                if values.count == 2 {
                    return Double(values[0])! + Double(values[1])!
                }
                if op == operations.count - 1 {
                        values[op] = String(Double(values[op])! + Double(values[op+1])!)
                        values.remove(at: op+1)
                }
                else {
                    values[operations.count - op - 2] = String(Double(values[operations.count - op - 2])! + Double(values[operations.count - op - 1])!)
                    values.remove(at: operations.count - op - 1)
                }
            }
        }
        for op in 0..<operations.count {
            if operations[op] == "-" {
                if values.count == 2 {
                    return Double(values[0])! - Double(values[1])!
                }
                if op == operations.count - 1 {
                        values[op] = String(Double(values[op])! - Double(values[op+1])!)
                        values.remove(at: op+1)
                }
                else {
                    values[operations.count - op - 2] = String(Double(values[operations.count - op - 2])! - Double(values[operations.count - op - 1])!)
                    values.remove(at: operations.count - op - 1)
                }
            }
        }

        
        return Double(values[0])!
    }
    
    @objc func numberButtonPressed(_ sender: UIButton!) {
        let digit = Int(sender.titleLabel?.text ?? "0")
        calcLabelContent += String(digit!)
        if calcLabelContent.count > 12 {
            calcLabel.text = String(calcLabelContent.suffix(15))
        }
        else {
            calcLabel.text = calcLabelContent
        }
        
        answerLabelValue = calcAnswerDMAS(calcLabelContent)
        if answerLabelValue > Double(Int.max) || answerLabelValue < Double(Int.min) {
            answerLabel.text = "Number Limit!"
            return
        }
        if Double(Int(answerLabelValue)) == answerLabelValue {
            answerLabelContent = String(Int(answerLabelValue))
        }
        else {
            answerLabelContent = String(answerLabelValue)
        }
        answerLabel.text = answerLabelContent
        calcLabelValue = 0
    }
    
    @objc func actionButtonPressed(_ sender: UIButton!) {
        answerLabelValue = calcAnswerDMAS(calcLabelContent)
        if Double(Int(answerLabelValue)) == answerLabelValue {
            answerLabelContent = String(Int(answerLabelValue))
        }
        else {
            answerLabelContent = String(answerLabelValue)
        }
        answerLabel.text = answerLabelContent
        let action = sender.titleLabel?.text
        if action != "=" {
            calcLabelContent += action!
        }
        if calcLabelContent.count > 12 {
            calcLabel.text = String(calcLabelContent.suffix(15))
        }
        else {
            calcLabel.text = calcLabelContent
        }
        switch action {
            case "=":
                calcLabelContent = answerLabelContent!
                calcLabel.text = calcLabelContent
                answerLabelContent = ""
                answerLabel.text = answerLabelContent
            default:
                break
                
        }
    }
    
    @objc func specialButtonPressed(_ sender: UIButton!) {
        let specialOperation = sender.titleLabel?.text
        if specialOperation != "AC" {
            answerLabelValue = calcAnswerDMAS(calcLabelContent)
            if Double(Int(answerLabelValue)) == answerLabelValue {
                answerLabelContent = String(Int(answerLabelValue))
            }
            else {
                answerLabelContent = String(answerLabelValue)
            }
            answerLabel.text = answerLabelContent
        }
        switch specialOperation! {
            case "AC":
                calcLabelContent = ""
                calcLabel.text = calcLabelContent
                
                answerLabelContent = ""
                answerLabel.text = answerLabelContent
            case "+/-":
                if calcLabelContent.prefix(1) == "-" {
                    calcLabelContent = String(calcLabelContent.suffix(calcLabelContent.count - 1))
                }
                else {
                    calcLabelContent = "-" + calcLabelContent
                }
                if calcLabelContent.count > 12 {
                    calcLabel.text = String(calcLabelContent.suffix(15))
                }
                else {
                    calcLabel.text = calcLabelContent
                }
            case "del":
                if calcLabelContent.count > 0 {
                    calcLabelContent = String(calcLabelContent.prefix(calcLabelContent.count - 1))
                }
                if calcLabelContent.count > 12 {
                    calcLabel.text = String(calcLabelContent.suffix(15))
                }
                else {
                    calcLabel.text = calcLabelContent
                }
            default:
                print("Error")
        }
    }
    
    @objc func contrastModeToggled(_ sender: UIButton) {
        self.isLightMode.toggle()
        overrideUserInterfaceStyle = isLightMode ? .light : .dark
        self.view.backgroundColor = isLightMode ? .white : .black
        
        titleLabel.textColor = isLightMode ? .darkGray : UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        contrastModeButton.setImage(UIImage(systemName: isLightMode ? "moon.fill" : "sun.max.fill"), for: .normal)
        contrastModeButton.imageView?.tintColor = isLightMode ? .white : .black
        contrastModeButton.backgroundColor = isLightMode ? .black : .white
        for button in numberButtons {
            button.setTitleColor(isLightMode ? UIColor.white : UIColor.black, for: .normal)
            button.layer.borderColor = isLightMode ? UIColor.white.cgColor : UIColor.black.cgColor
        }
        for button in actionButtons.values {
            button.setTitleColor(isLightMode ? UIColor.white : UIColor.black, for: .normal)
            button.layer.borderColor = isLightMode ? UIColor.white.cgColor : UIColor.black.cgColor
        }
        for button in specialButtons.values {
            button.setTitleColor(isLightMode ? UIColor.white : UIColor.black, for: .normal)
            button.layer.borderColor = isLightMode ? UIColor.white.cgColor : UIColor.black.cgColor
        }
    }

    func setAutoConstraints(someView: UIView, width: CGFloat, height: CGFloat, xOffset: CGFloat, yOffset: CGFloat, xRelative: Bool, yRelative: Bool, xLeading: Bool, yTop: Bool) {
            
        someView.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = NSLayoutConstraint(
           item: someView,
           attribute: NSLayoutConstraint.Attribute.width,
           relatedBy: NSLayoutConstraint.Relation.equal,
           toItem: nil,
           attribute: NSLayoutConstraint.Attribute.notAnAttribute,
           multiplier: 1,
           constant: width
        )
        let heightConstraint = NSLayoutConstraint(
           item: someView,
           attribute: NSLayoutConstraint.Attribute.height,
           relatedBy: NSLayoutConstraint.Relation.equal,
           toItem: nil,
           attribute: NSLayoutConstraint.Attribute.notAnAttribute,
           multiplier: 1,
           constant: height
        )
        var xConstraint = NSLayoutConstraint(
            item: someView,
            attribute: NSLayoutConstraint.Attribute.centerX,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: view,
            attribute: NSLayoutConstraint.Attribute.centerX,
            multiplier: 1,
            constant: 0
        )
        var yConstraint = NSLayoutConstraint(
            item: someView,
            attribute: NSLayoutConstraint.Attribute.centerY,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: view,
            attribute: NSLayoutConstraint.Attribute.centerY,
            multiplier: 1,
            constant: 0
        )
        if xRelative {
            if xLeading {
                xConstraint = NSLayoutConstraint(
                   item: someView,
                   attribute: NSLayoutConstraint.Attribute.leading,
                   relatedBy: NSLayoutConstraint.Relation.equal,
                   toItem: view,
                   attribute: NSLayoutConstraint.Attribute.leadingMargin,
                   multiplier: 1.0,
                   constant: xOffset
                )
            }
            else {
                xConstraint = NSLayoutConstraint(
                   item: someView,
                   attribute: NSLayoutConstraint.Attribute.trailing,
                   relatedBy: NSLayoutConstraint.Relation.equal,
                   toItem: view,
                   attribute: NSLayoutConstraint.Attribute.trailingMargin,
                   multiplier: 1.0,
                   constant: -xOffset
                )
            }
            
        }
        if yRelative {
            if yTop {
                yConstraint = NSLayoutConstraint(
                    item: someView,
                    attribute: NSLayoutConstraint.Attribute.top,
                    relatedBy: NSLayoutConstraint.Relation.equal,
                    toItem: view,
                    attribute: NSLayoutConstraint.Attribute.topMargin,
                    multiplier: 1.0,
                    constant: yOffset
                )
            }
            else {
                yConstraint = NSLayoutConstraint(
                    item: someView,
                    attribute: NSLayoutConstraint.Attribute.bottom,
                    relatedBy: NSLayoutConstraint.Relation.equal,
                    toItem: view,
                    attribute: NSLayoutConstraint.Attribute.bottomMargin,
                    multiplier: 1.0,
                    constant: -yOffset
                )
            }
            
        }
        view.addConstraints(
                    [widthConstraint, heightConstraint, xConstraint, yConstraint]
            )
    }
    
    fileprivate func setTitleLabel(_ screenWidth: CGFloat, _ screenHeight: CGFloat) {
        titleLabel.text = "simply calcy"
        titleLabel.textColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: screenWidth / 10 + 1)
        titleLabel.textAlignment = .right
        self.view.addSubview(titleLabel)
        setAutoConstraints(someView: titleLabel, width: screenWidth, height: screenHeight / 8, xOffset: 0.0, yOffset: 0.0, xRelative: true, yRelative: true, xLeading: true, yTop: true)
    }
    
    fileprivate func setAnswerLabel(_ screenWidth: CGFloat, _ screenHeight: CGFloat) {
        answerLabel.text = answerLabelContent
        answerLabel.font = UIFont(name: "AvenirNext-Bold", size: screenWidth / 10 - 2)
        answerLabel.textAlignment = .right
        answerLabel.textColor = .darkGray
        self.view.addSubview(answerLabel)
        setAutoConstraints(someView: answerLabel, width: screenWidth, height: screenHeight / 8, xOffset: 0.0, yOffset: 2 * screenHeight / 8, xRelative: true, yRelative: true, xLeading: true, yTop: true)
    }
    
    fileprivate func setCalcLabel(_ screenWidth: CGFloat, _ screenHeight: CGFloat) {
        calcLabel.numberOfLines = 2
        calcLabel.text = calcLabelContent
        calcLabel.font = UIFont(name: "AvenirNext-Bold", size: screenWidth / 10 - 2)
        calcLabel.textAlignment = .right
        calcLabel.textColor = .white
        calcLabel.backgroundColor = .darkGray
        calcLabel.clipsToBounds = true
        calcLabel.layer.cornerRadius = 10
        self.view.addSubview(calcLabel)
        setAutoConstraints(someView: calcLabel, width: screenWidth, height: screenHeight / 8, xOffset: 0.0, yOffset: screenHeight / 8, xRelative: true, yRelative: true, xLeading: true, yTop: true)
    }
    
    fileprivate func setNumberButtons(_ screenWidth: CGFloat, _ screenHeight: CGFloat) {
        numberButtons.append(createButton(title: "0", backgroundColor: UIColor(red: 0.0, green: 0.6549, blue: 0.9765, alpha: 1.0)))
        self.view.addSubview(numberButtons[0])
        setAutoConstraints(someView: numberButtons[0], width: 2 * screenWidth / 4, height: screenHeight / 9, xOffset: 0.0, yOffset: 0.0, xRelative: true, yRelative: true, xLeading: true, yTop: false)
        numberButtons[0].addTarget(self, action: #selector(numberButtonPressed(_:)), for: .touchUpInside)
        
        for i in 1...9 {
            numberButtons.append(createButton(title: "\(i)", backgroundColor: UIColor(red: 0.0, green: 0.6549, blue: 0.9765, alpha: 1.0)))
            self.view.addSubview(numberButtons[i])
            let mod = (i - 1) % 3
            let quo = (i - 1) / 3
            setAutoConstraints(someView: numberButtons[i], width: screenWidth / 4, height: screenHeight / 9, xOffset: CGFloat(mod) * screenWidth / 4, yOffset: CGFloat(quo + 1) * screenHeight / 9, xRelative: true, yRelative: true, xLeading: true, yTop: false)
            numberButtons[i].addTarget(self, action: #selector(numberButtonPressed(_:)), for: .touchUpInside)
        }
    }
    
    fileprivate func setActionButtons(_ screenWidth: CGFloat, _ screenHeight: CGFloat) {
        actionButtons["."] = createButton(title: ".", backgroundColor: UIColor(red: 0.0, green: 0.6549, blue: 0.9765, alpha: 1.0))
        self.view.addSubview(actionButtons["."]!)
        setAutoConstraints(someView: actionButtons["."]!, width: screenWidth / 4, height: screenHeight / 9, xOffset: 2 * screenWidth / 4, yOffset: 0.0, xRelative: true, yRelative: true, xLeading: true, yTop: false)
        actionButtons["."]!.addTarget(self, action: #selector(actionButtonPressed(_:)), for: .touchUpInside)

        
        for (i, op) in operations.enumerated() {
            actionButtons[op] = createButton(title: op, backgroundColor: UIColor(red: 1.0, green: 0.5373, blue: 0.0, alpha: 1.0))
            self.view.addSubview(actionButtons[op]!)
            setAutoConstraints(someView: actionButtons[op]!, width: screenWidth / 4, height: screenHeight / 9, xOffset: 0.0, yOffset: CGFloat(i) * screenHeight / 9, xRelative: true, yRelative: true, xLeading: false, yTop: false)
            actionButtons[op]!.addTarget(self, action: #selector(actionButtonPressed(_:)), for: .touchUpInside)

        }
    }
    
    fileprivate func setSpecialButtons(_ screenWidth: CGFloat, _ screenHeight: CGFloat) {
        for (i, so) in specialOperations.enumerated() {
            specialButtons[so] = createButton(title: so, backgroundColor: UIColor(red: 0.3333, green: 0.3333, blue: 0.3333, alpha: 1.0))
            self.view.addSubview(specialButtons[so]!)
            setAutoConstraints(someView: specialButtons[so]!, width: screenWidth / 4, height: screenHeight / 9, xOffset: CGFloat(i) * screenWidth / 4, yOffset: 4 * screenHeight / 9, xRelative: true, yRelative: true, xLeading: true, yTop: false)
            specialButtons[so]!.addTarget(self, action: #selector(specialButtonPressed(_:)), for: .touchUpInside)
        }
    }
}

@IBDesignable class PaddingLabel: UILabel {

    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 7.0
    @IBInspectable var rightInset: CGFloat = 7.0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }

    override var bounds: CGRect {
        didSet {
            // ensures this works within stack views if multi-line
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
}
