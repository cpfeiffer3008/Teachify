//
//  SubjectCollectionView.swift
//  Teachify
//
//  Created by Bastian Kusserow on 12.04.18.
//  Copyright © 2018 Christian Pfeiffer. All rights reserved.
//

import UIKit

class SubjectCollectionView: UIView, ItemSelectedCallback {
   
    
    private let dataSource = SubjectCollectionViewDataSource()
    private let delegate = CenteredCollectionViewDelegate()
    private var leftConstraint : NSLayoutConstraint!
    private var triangleView : UIImageView!
    
    lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = dataSource
        cv.delegate = delegate
        cv.backgroundColor = UIColor.clear
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        delegate.callback = self
        self.addSubview(collectionView)
        addConstraints(withFormat: "H:|[v0]|", forViews: collectionView)
        addConstraints(withFormat: "V:|[v0]|", forViews: collectionView)
        
        collectionView.register(SubjectCell.self, forCellWithReuseIdentifier: "subjectCell")
        collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: [])
        
        triangleView = UIImageView(image: #imageLiteral(resourceName: "triangle"))
        
        addSubview(triangleView)
        triangleView.translatesAutoresizingMaskIntoConstraints = false
        triangleView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 2).isActive = true
        leftConstraint = triangleView.leftAnchor.constraint(equalTo: collectionView.leftAnchor, constant: frame.width/2-triangleView.frame.width/2)
        leftConstraint.isActive = true

    }
    
    func didSelectItem(at position: Int) {
        let aClickedCell = collectionView.cellForItem(at: IndexPath(row: position, section: 0))
        guard let clickedCell = aClickedCell else {return}
        
        let middleOfClickedCell = clickedCell.frame.minX + clickedCell.frame.width/2 - triangleView.frame.width/2
            self.leftConstraint.constant = middleOfClickedCell - collectionView.contentOffset.x
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.layoutIfNeeded()
            }, completion: nil)
    }
    

}

protocol ItemSelectedCallback{
    func didSelectItem(at position: Int)
}


