//
//  SegmentCell.swift
//  Teachify
//
//  Created by Bastian Kusserow on 17.04.18.
//  Copyright © 2018 Christian Pfeiffer. All rights reserved.
//

import UIKit

class SegmentCell: UICollectionViewCell {
    
    
    
    @IBOutlet var cellTitle: UILabel!
    
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var count: UILabel!
    
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.teacherSelectedLightBlue : UIColor.teacherLightBlue
        }
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor.teacherSelectedLightBlue : UIColor.teacherLightBlue
        }
    }
}
