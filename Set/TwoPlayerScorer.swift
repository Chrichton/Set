//
//  TwoPlayerScorer.swift
//  Set
//
//  Created by Heiko Goes on 28.09.18.
//  Copyright © 2018 Heiko Goes. All rights reserved.
//

import Foundation

struct TwoPlayerScorer: ScoringProtocol {
    // Strategy TODO
    mutating func getNewScore(for game: Game) -> Int? {
        if game.selectedCards.count == 3 &&
            game.selectedCards.allSatisfy{selectedCard in game.matchedCards.contains(selectedCard)} {
            return 1
        }
        
        return nil
    }
}
