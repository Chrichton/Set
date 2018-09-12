//
//  Card.swift
//  Set
//
//  Created by Heiko Goes on 30.08.18.
//  Copyright © 2018 Heiko Goes. All rights reserved.
//

import Foundation

struct Card: Equatable {
    enum CardColors {
        case color1
        case color2
        case color3
        
        static let allValues = [color1, color2, color3]
    }
    
    enum CardSymbols {
        case symbol1
        case symbol2
        case symbol3
        
        static let allValues = [symbol1, symbol2, symbol3]
    }
    
    enum CardShadings {
        case shading1
        case shading2
        case shading3
        
        static let allValues = [shading1, shading2, shading3]
    }
    
    let color: CardColors
    let rank: Int
    let symbol: CardSymbols
    let shading: CardShadings
}

