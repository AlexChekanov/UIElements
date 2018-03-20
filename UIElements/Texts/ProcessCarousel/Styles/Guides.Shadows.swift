//
//  Guides.Shadows.swift
//  Guidelines
//
//  Created by Alexey Chekanov on 7/11/17.
//  Copyright © 2017 Alexey Chekanov. All rights reserved.
//

import Foundation
import UIKit
import Styles

// MARK: - Shadow styles
extension Shadow {
    static var none: Shadow {
        return Shadow(shadowColor: .clear, shadowOffset: CGSize.zero, shadowRadius: 0, shadowOpacity: 0, masksToBound: nil)
    }
    
    static var soft: Shadow {
        return Shadow(shadowColor: .black, shadowOffset: CGSize(width: 0.0, height: 6.0), shadowRadius: 8, shadowOpacity: 0.8, masksToBound: false)
    }
    
    static var hard: Shadow {
        return Shadow(shadowColor: .black, shadowOffset: CGSize(width: 0.0, height: 6.0), shadowRadius: 4, shadowOpacity: 1, masksToBound: false)
    }
}
