//
//  ScoringProtocol.swift
//  Set
//
//  Created by Heiko Goes on 08.10.18.
//  Copyright © 2018 Heiko Goes. All rights reserved.
//

import Foundation

protocol ScoringProtocol {
    mutating func getNewScore(for game: Game) -> Int?
    var hasNewScore: Bool {get} 
}
