//
//  ViewController.swift
//  Set
//
//  Created by Heiko Goes on 30.08.18.
//  Copyright © 2018 Heiko Goes. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBAction func touchCard(_ sender: UIButton) {
        if let cardNumber = cardButtons.index(of: sender) {
            game.selectCard(atIndex: cardNumber)
            updateViewFromModel()
        }
    }
   
    @IBAction func findMatch(_ sender: UIButton) {
        startMatchFinder()
    }
    
    @IBOutlet var cardButtons: [UIButton]!
    
    var game: Game!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        game = Game()
        updateViewFromModel()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func updateViewFromModel() {
        for (index, card) in game.cards.enumerated() {
            let buttonText = cardToButtonText(card)
            let cardButton = cardButtons[index]
            cardButton.setAttributedTitle(buttonText, for: .normal)
            
            if game.selectedCards.contains(card) {
                cardButton.layer.borderWidth = 3
                if game.matchedCards.contains(card) {
                   cardButton.layer.borderColor = UIColor.green.cgColor
                } else {
                    cardButton.layer.borderColor = UIColor.blue.cgColor
                }
            } else {
                cardButton.layer.borderWidth = 0
            }
        }
        
        for i in game.cards.count ..< cardButtons.count {
            cardButtons[i].backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    private func cardToButtonText(_ card: Card) -> NSAttributedString {
        var symbol: String!
        switch card.symbol {
        case .symbol1:
            symbol = "▲"
        case .symbol2:
            symbol = "●"
        case .symbol3:
            symbol = "◼︎"
        }
        
 //       let string = String(repeating: symbol, count: card.numberOfSymbols)
        
        var attributes = [NSAttributedStringKey : Any]()
        
        switch card.color {
        case .color1:
            attributes[NSAttributedStringKey.foregroundColor] = UIColor.red
        case .color2:
            attributes[NSAttributedStringKey.foregroundColor] = UIColor.green
        case .color3:
            attributes[NSAttributedStringKey.foregroundColor] = UIColor.yellow
        }
        
        switch card.shading {
        case .shading1:
            attributes[NSAttributedStringKey.strokeWidth] = 10  // Outline
        case .shading2:
            () // Solid
        case .shading3:
            attributes[NSAttributedStringKey.foregroundColor] = (attributes[NSAttributedStringKey.foregroundColor] as! UIColor).withAlphaComponent(0.35)
        }
        
        return NSAttributedString(string: symbol, attributes: attributes)
    }
    
    private func startMatchFinder() {
        let backgroundQueue = DispatchQueue.global(qos: .background)
        backgroundQueue.async {
            if let matchingCards = self.game.findMatchingCards() {
                DispatchQueue.main.async {
                    self.game.selectMatchingCards(matchingCards)
                    self.updateViewFromModel()
                }
            }
        }
    }
}

