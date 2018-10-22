//
//  Game.swift
//  Set
//
//  Created by Heiko Goes on 30.08.18.
//  Copyright © 2018 Heiko Goes. All rights reserved.
//

import Foundation

struct Game {
    typealias MatchingCards = (card1: Card, card2: Card, card3: Card)
    
    private (set) var cards = [Card]()
    private (set) var selectedCards = [Card]()
    private (set) var matchedCards  = [Card]()
    private (set) var newCards  = [Card]()
    private (set) var scorer: ScoringProtocol
    private (set) var players = CircularSequence<Player>()
    
    private var hasNewCards = true
    private var remainingDeck = [Card]()
    private let noOfCardsAtStart = 12
    
        // TODO
    init(numberOfPlayers: Int) { // Cartesian Product
        for color in Card.CardColors.allCases {
            for symbol in Card.CardSymbols.allCases {
                for shading in Card.CardShadings.allCases {
                    for rank in 1...3 {
                        remainingDeck.append(Card(color: color, rank: rank, symbol: symbol, shading: shading))
                    }
                }
            }
        }
        
        scorer = TwoPlayerScorer()
        
        remainingDeck = shuffleCards(remainingDeck)
        for _ in 1...noOfCardsAtStart {
            appendCard(remainingDeck.remove(at: 0))
        }
        
        for playerNumber in 1...numberOfPlayers {
            players.append(Player(name: "Spieler\(playerNumber)", score: 0))
        }
    }
    
    mutating func nextPlayer() -> Void {
        let _ = players.next()
    }
    
    private mutating func appendCard(_ newCard: Card) {
        cards.append(newCard)
        newCards.append(newCard)
        hasNewCards = true
    }

    private mutating func insertCard(_ newCard: Card, at: Int) {
        cards.insert(newCard, at: at)
        newCards.append(newCard)
        hasNewCards = true
    }
    
    private mutating func updateScore() {
        if let newScore = scorer.getNewScore(for: self), let player = players.current() {
            let newPlayer = Player(name: player.name, score: player.score + newScore)
            players.setValue(atIndex: players.position, to: newPlayer)
        }
    }
    
    private mutating func updateNewCards() {
        if hasNewCards {
            newCards.removeAll()
            hasNewCards = false
        }
    }
    
    mutating func selectCard(atIndex: Int) {
        assert(selectedCards.count < 3)
        
        updateNewCards()
        
        let selectedCard = cards[atIndex]
        if let index = selectedCards.index(of: selectedCard) {
            selectedCards.remove(at: index)
        } else {
            selectedCards.append(selectedCard)
            if selectedCards.count == 3 {
                let match = isMatch(card1: selectedCards[0], card2: selectedCards[1], card3: selectedCards[2])
                if match {
                    matchedCards.append(contentsOf: selectedCards)
                }
            }
        }
        
        updateScore()
    }
    
    mutating func deSelectCards() {
        selectedCards.removeAll()
    }
    
    mutating func selectMatchingCards(_ matchingCards: MatchingCards)  {
        let matchingCardsArray = [matchingCards.card1, matchingCards.card2, matchingCards.card3]
        selectedCards.removeAll()
        selectedCards.append(contentsOf: matchingCardsArray)
        matchedCards.append(contentsOf: matchingCardsArray)
        updateScore()
    }
    
    mutating func findMatchingCards() -> MatchingCards? {
        updateNewCards()
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
    
    mutating func deal3Cards() {
        updateNewCards()
        if selectedCards.count == 3 &&
            matchedCards.contains(selectedCards[0]) && matchedCards.contains(selectedCards[1]) && matchedCards.contains(selectedCards[2]) {
            for card in selectedCards {
                if let index = cards.index(of: card) {
                    cards.remove(at: index)
                    if !remainingDeck.isEmpty && cards.count < noOfCardsAtStart {
                        let remainingCard = remainingDeck.remove(at: 0)
                        insertCard(remainingCard, at: index)
                    }
                }
            }
            selectedCards.removeAll()
        } else {
            for _ in 1...3 {
                if !remainingDeck.isEmpty {
                    let card = remainingDeck.remove(at: 0)
                    appendCard(card)
                }
            }
        }
    }
    
    var hasRemainingCards: Bool {
        return remainingDeck.count > 0
    }
    
    mutating func reshuffleCards() {
        let cardsDrawn = cards.count
        remainingDeck = shuffleCards(cards + remainingDeck)
        cards.removeAll()
        while cards.count < cardsDrawn {
            appendCard(remainingDeck.remove(at: 0))
        }
    }
    
    private func isMatch(card1: Card, card2: Card, card3: Card) -> Bool {
        return  (card1.color != card2.color && card1.color != card3.color && card2.color != card3.color || card1.color == card2.color && card2.color == card3.color) &&
                (card1.shading != card2.shading && card1.shading != card3.shading && card2.shading != card3.shading || card1.shading == card2.shading && card2.shading == card3.shading) &&
                (card1.symbol != card2.symbol && card1.symbol != card3.symbol && card2.symbol != card3.symbol || card1.symbol == card2.symbol && card2.symbol == card3.symbol)  &&
                (card1.rank != card2.rank && card1.rank != card3.rank && card2.rank != card3.rank || card1.rank == card2.rank && card2.rank == card3.rank)
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
