//
//  HeaderCollectionReusableView.swift
//  UIElements
//
//  Created by Alexey Chekanov on 3/17/18.
//  Copyright © 2018 Tips & Tricks, LLC. All rights reserved.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //MARK: - Controls
    var viewState: ProcessControl.CollectionState = .normal {
        didSet {
            switch self.viewState {
            case .normal: setViewToNormalMode()
            case .editing: setViewToEditingMode()
            case .rearrangement: setViewToRearrangementMode()
            }
        }
    }
    
    func setViewToNormalMode() {}
    func setViewToEditingMode(){}
    func setViewToRearrangementMode() {}
}

