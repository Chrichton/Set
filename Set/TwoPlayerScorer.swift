//
//  TwoPlayerScorer.swift
//  Set
//
//  Created by Heiko Goes on 28.09.18.
//  Copyright © 2018 Heiko Goes. All rights reserved.
//

import Foundation

struct TwoPlayerScorer: ScoringProtocol {
    private var newScore = false
    
    var hasNewScore: Bool {
        get { return newScore }
    }
        
    // Strategy TODO
    mutating func getNewScore(for game: Game) -> Int? {
        if game.selectedCards.count == 3 &&
            game.selectedCards.allSatisfy{selectedCard in game.matchedCards.contains(selectedCard)} {
            newScore = true
            return 1
        }
        
        newScore = false
        return nil
    }
}
