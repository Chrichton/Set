//
//  TwoPlayerScorer.swift
//  Set
//
//  Created by Heiko Goes on 28.09.18.
//  Copyright © 2018 Heiko Goes. All rights reserved.
//

import Foundation

struct TwoPlayerScorer {
    enum Players {
        case playerOne
        case playerTwo
    }
    
    private (set) var PlayerOneScore = 0
    private (set) var PlayerTwoScore = 0
    mutating func playerDidDraw(player: Players, for game: Game) {
        if let newScore = getNewScore(game: game) {
            switch player {
            case .playerOne:
                PlayerOneScore += newScore
            case .playerTwo:
                PlayerTwoScore += newScore
            }
        }
    }
    
    private func getNewScore(game: Game) -> Int? {
        if game.selectedCards.count == 3 &&
            game.selectedCards.allSatisfy{selectedCard in game.matchedCards.contains(selectedCard)} {
            return 1
        }
        
        return nil
    }
}
