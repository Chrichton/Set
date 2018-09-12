//
//  ViewController.swift
//  Set
//
//  Created by Heiko Goes on 30.08.18.
//  Copyright © 2018 Heiko Goes. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @objc
    func touchCard(_ sender: UITapGestureRecognizer) {
        if let tappedView = sender.view {
            let index = tappedView.tag
            game.selectCard(atIndex: index)
            updateViewFromModel()
        }
    }
   
    @IBAction func findMatch(_ sender: UIButton) {
        startMatchFinder()
    }
    
    @IBAction func moreCards(_ sender: UIButton) {
        game.drawCards()
        updateViewFromModel()
    }
    
    @IBAction func newGame(_ sender: UIButton) {
        game = Game()
        updateViewFromModel()
    }
    
    @IBOutlet var moreCardsButton: UIButton!
    @IBOutlet var playingCardsView: UIView!
    
    lazy var game: Game = Game()
    lazy var grid = Grid(layout: .aspectRatio(5.0 / 8.0), frame: playingCardsView.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViewFromModel()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateViewFromModel() {
        removeOldPlayingCardViews()
        grid.cellCount = game.cards.count
        for (index, card) in game.cards.enumerated() {
            if let frame = grid[index] {
                let cardView = PlayingCardView(frame: frame.insetBy(dx: 3, dy: 3))
                switch card.color {
                case .color1: cardView.suitColor = UIColor.red
                case .color2: cardView.suitColor = UIColor.blue
                case .color3: cardView.suitColor = UIColor.green
                }
                switch card.shading {
                case .shading1: cardView.shading = .filled
                case .shading2: cardView.shading = .open
                case .shading3: cardView.shading = .striped
                }
                switch card.symbol {
                case .symbol1 : cardView.suit = .diamond
                case .symbol2: cardView.suit = .oval
                case .symbol3: cardView.suit = .squiggle
                }
                cardView.rank = Rank(rawValue: card.rank) ?? .one
                
                if game.selectedCards.contains(card) {
                    if game.matchedCards.contains(card) {
                        cardView.cardColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
                    } else {
                        cardView.cardColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
                    }
                } else {
                    cardView.cardColor = UIColor.white
                }
                
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchCard(_:)))
                cardView.addGestureRecognizer(tapGestureRecognizer)
                cardView.tag = index
                playingCardsView.addSubview(cardView)
                moreCardsButton.isEnabled = game.hasRemainingCards
            }
        }
    }
    
    private func removeOldPlayingCardViews() {
        for view in playingCardsView.subviews {
            if view is PlayingCardView {
                view.removeFromSuperview()
            }
        }
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

