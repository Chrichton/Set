//
//  PlayingCardView.swift
//  Set
//
//  Created by Heiko Goes on 05.09.18.
//  Copyright © 2018 Heiko Goes. All rights reserved.
//

import UIKit
import CoreGraphics

enum Suit: Int {
    case diamond
    case oval
    case squiggle
    
    // func createPath TODO
}

enum Rank: Int {
    case one = 1
    case two = 2
    case three = 3
}

enum Shading: Int {
    case filled
    case open
    case striped
}

extension Card.CardColors {
    func getUIColor() -> UIColor {
        switch self {
        case .color1: return UIColor.red
        case .color2: return UIColor.green
        case .color3: return UIColor.blue
        }
    }
}
// suitColor als enum

@IBDesignable class PlayingCardView: UIView {
    @IBInspectable var cardColor: UIColor = UIColor.white
    @IBInspectable var suitColor: UIColor = UIColor.red
    @IBInspectable var suitAdapter: Int {
        get {
            return self.suit.rawValue
        }
        set(suitIndex) {
            self.suit = Suit(rawValue: suitIndex) ?? .diamond
        }
    }
    @IBInspectable var rankAdapter: Int {
        get {
            return self.rank.rawValue
        }
        set(rankIndex) {
            self.rank = Rank(rawValue: rankIndex) ?? .three
        }
    }
    @IBInspectable var shadingAdapter: Int {
        get {
            return self.shading.rawValue
        }
        set(shadingIndex) {
            self.shading = Shading(rawValue: shadingIndex) ?? .filled
        }
    }
    
    var suit: Suit = .diamond
    var rank: Rank = .three
    var shading: Shading = .filled
    
    private func createOvalPath(inRect: CGRect) -> UIBezierPath {
        let radius = inRect.height / 2
        let path = UIBezierPath()

        let centerLeft = CGPoint(x: inRect.minX + radius, y: inRect.minY + radius)
        path.addArc(withCenter: centerLeft, radius: radius, startAngle: CGFloat.pi / 2, endAngle: CGFloat.pi * 3 / 2, clockwise: true)
        path.addLine(to: CGPoint(x: inRect.maxX - radius, y: inRect.minY))
        
        let centerRight = CGPoint(x: inRect.maxX - radius, y: inRect.minY + radius)
        path.addArc(withCenter: centerRight, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi / 2, clockwise: true)
//        oval.addLine(to: CGPoint(x: inRect.minX + radius, y: inRect.maxY))
        path.close()
 
        return path
    }
    
    private func createDiamondPath(inRect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: inRect.minX + inRect.width / 2, y: inRect.minY))
        path.addLine(to: CGPoint(x: inRect.minX, y: inRect.minY + inRect.height / 2))
        path.addLine(to: CGPoint(x: inRect.minX + inRect.width / 2, y: inRect.maxY))
        path.addLine(to: CGPoint(x: inRect.maxX, y: inRect.minY + inRect.height / 2))
        path.close()
        
        return path
    }
    
    private func createWrigglyPath(inRect: CGRect) -> UIBezierPath {
        let circleRect = CGRect(x: inRect.minX + inRect.width / 2 - inRect.height / 2, y: inRect.minY, width: inRect.height, height: inRect.height)
        return UIBezierPath(ovalIn: circleRect)
    }
    
    typealias DrawFunc = (CGRect) -> Void
    
    private func createSuitPath(inRect: CGRect) -> UIBezierPath {
        switch suit {
        case .diamond: return createDiamondPath(inRect: inRect)
        case .oval: return createOvalPath(inRect: inRect)
        case .squiggle: return createWrigglyPath(inRect: inRect)
        }
    }
    
    private func createSymbolDrawFunc() -> DrawFunc {
        return
            {
                rect -> Void in
                let path = self.createSuitPath(inRect: rect)
                
                switch self.shading {
                case .open, .striped: // 2 Fälle für .open, .striped TODO
                    if let currentContext = UIGraphicsGetCurrentContext() {
                        currentContext.saveGState()
                    }
                    path.lineWidth = 2
                    self.suitColor.setStroke()
                    if self.shading == .striped {
                        path.addClip()
                        stride(from: rect.minX + path.lineWidth, to: rect.maxX, by: 4 * path.lineWidth)
                            .forEach { x in
                                path.move(to: CGPoint(x: x, y: rect.minY))
                                path.addLine(to: CGPoint(x: x, y: rect.maxY))
                        }
                    }
                    path.stroke()
                    if let currentContext = UIGraphicsGetCurrentContext() {
                        currentContext.restoreGState()
                    }
                case .filled:
                    self.suitColor.setFill()
                    path.fill()
                }
            }
    }
    
    private func drawSymbol(rect: CGRect) {
        let drawFunc = createSymbolDrawFunc()
        
        let partitionX: CGFloat = 6
        let partitionY: CGFloat = 5
        let width = (1 - 2 / partitionX) * rect.width
        let height = rect.height / partitionY
        let x = rect.minX + rect.width / partitionX
        let symbolsPadding = 1 / (8 * partitionY)
        
        switch rank {
        case .one:
            let symbolRect = CGRect(x: x, y: rect.minY + 2 / partitionY * rect.height, width: width , height: height)
            drawFunc(symbolRect)
        case .two: // Nur oberes Rect bestimmen und dann um dieselbe Höhe y verschieben
            let symbolRectUp = CGRect(x: x, y: rect.minY + (2 / partitionY - 1 / (2 * partitionY) - symbolsPadding) * rect.height, width: width, height: height)
            drawFunc(symbolRectUp)
            let symbolRectDown = CGRect(x: x, y: rect.minY + (2 / partitionY + 1 / (2 * partitionY) + symbolsPadding) * rect.height, width: width, height: height)
            drawFunc(symbolRectDown)
        case .three: // TODO Sequence von drawFuncs
            let symbolRectUp = CGRect(x: x, y: rect.minY + (1 / partitionY  - symbolsPadding) * rect.height, width: width, height: height)
            drawFunc(symbolRectUp)
            let symbolMidddle = CGRect(x: x, y: rect.minY + 2 / partitionY * rect.height, width: width , height: height)
            drawFunc(symbolMidddle)
            let symbolRectDown = CGRect(x: x, y: rect.minY + (3 / partitionY + symbolsPadding) * rect.height, width: width, height: height)
            drawFunc(symbolRectDown)
        }
    }
    
    fileprivate func drawCardBackground(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: 20)
        roundedRect.addClip()
        cardColor.setFill()
        roundedRect.fill()
    }
    
    override func draw(_ rect: CGRect) {
        drawCardBackground(rect)
        drawSymbol(rect: rect)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    }
}
