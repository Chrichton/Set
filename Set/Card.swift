//
//  Card.swift
//  Set
//
//  Created by Heiko Goes on 30.08.18.
//  Copyright © 2018 Heiko Goes. All rights reserved.
//

import Foundation

struct Card: Equatable {
    enum CardColors: CaseIterable {
        case color1
        case color2
        case color3
    }
    
    enum CardSymbols: CaseIterable {
        case symbol1
        case symbol2
        case symbol3
    }
    
    enum CardShadings: CaseIterable {
        case shading1
        case shading2
        case shading3
    }
    
    let color: CardColors
    let rank: Int
    let symbol: CardSymbols
    let shading: CardShadings
    var isNew = true
    
    init(color: CardColors, rank: Int, symbol: CardSymbols, shading: CardShadings) {
        self.color = color
        self.rank = rank
        self.symbol = symbol
        self.shading = shading
    }
}

