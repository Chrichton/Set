//
//  Game.swift
//  Set
//
//  Created by Heiko Goes on 30.08.18.
//  Copyright © 2018 Heiko Goes. All rights reserved.
//

import Foundation

typealias MatchingCards = (card1: Card, card2: Card, card3: Card)

struct Game {
    private (set) var cards = [Card]()

    private var remainingDeck = [Card]()
    private (set) var selectedCards = [Card]()
    private (set) var matchedCards  = [Card]()
    
    init() {
        for color in Card.CardColors.allValues {
            for symbol in Card.CardSymbols.allValues {
                for shading in Card.CardShadings.allValues {
                    remainingDeck.append(Card(color: color, symbol: symbol, shading: shading))
//                    for numberOfSymbols in 1...3 {
//                        cards.append(Card(color: color, numberOfSymbols: numberOfSymbols, symbol: symbol, shading: shading))
//                    }
                }
            }
        }
        
        remainingDeck = shuffleCards(remainingDeck)
        for _ in 1...12 {
            cards.append(remainingDeck.remove(at: 0))
        }
    }
    
    mutating func selectCard(atIndex: Int) {
        let selectedCard = cards[atIndex]
        if selectedCards.count < 2 {
            if let index = selectedCards.index(of: selectedCard) {
                selectedCards.remove(at: index)
            } else {
                selectedCards.append(selectedCard)
            }
        } else if selectedCards.count == 2 {
            if let index = selectedCards.index(of: selectedCard) {
                selectedCards.remove(at: index)
            } else {
                selectedCards.append(selectedCard)
                let match = isMatch(card1: selectedCards[0], card2: selectedCards[1], card3: selectedCards[2])
                if match {
                    matchedCards.append(contentsOf: selectedCards)
                }
            }
        } else {
            if !selectedCards.contains(selectedCard) {
                if matchedCards.contains(selectedCards[0]) && matchedCards.contains(selectedCards[1]) && matchedCards.contains(selectedCards[2]) {
                    for card in selectedCards {
                        if !remainingDeck.isEmpty {
                            if let index = cards.index(of: card) {
                                cards.remove(at: index)
                                let remainingCard = remainingDeck.remove(at: 0)
                                cards.insert(remainingCard, at: index)
                            }
                        }
                    }
                }
                selectedCards.removeAll()
                selectedCards.append(selectedCard)
            }
        }
    }
    
    mutating func selectMatchingCards(_ matchingCards: MatchingCards)  {
            let matchingCardsArray = [matchingCards.card1, matchingCards.card2, matchingCards.card3]
            selectedCards.removeAll()
            selectedCards.append(contentsOf: matchingCardsArray)
            matchedCards.append(contentsOf: matchingCardsArray)
    }
    
    func findMatchingCards() -> MatchingCards? {
        for index1 in 0 ..< cards.count - 2 {
            for index2 in index1 + 1 ..< cards.count - 1 {
                for index3 in index2 + 1 ..< cards.count {
                    let card1 = cards[index1]
                    let card2 = cards[index2]
                    let card3 = cards[index3]
                    if isMatch(card1: card1, card2: card2, card3: card3) {
                        return (card1, card2, card3)
                    }
                }
            }
        }
        
        return nil
    }
    
    private func isMatch(card1: Card, card2: Card, card3: Card) -> Bool {
        return  card1.color != card2.color && card1.color != card3.color && card2.color != card3.color &&
                card1.shading != card2.shading && card1.shading != card3.shading && card2.shading != card3.shading &&
                card1.symbol != card2.symbol && card1.symbol != card3.symbol && card2.symbol != card3.symbol
    }
    
    private func shuffleCards(_ cards: [Card]) -> [Card] {
        var cards = cards
        var shuffledCards = [Card]()
        for maxCardIndex in (1...cards.count).reversed() {
            let cardIndex = Int(arc4random_uniform(UInt32(maxCardIndex)))
            shuffledCards.append(cards.remove(at: cardIndex))
        }
        
        return shuffledCards
    }
}
