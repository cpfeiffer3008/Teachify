//
//  ClassesCollectionViewDataSource.swift
//  Teachify
//
//  Created by Bastian Kusserow on 26.04.18.
//  Copyright © 2018 Christian Pfeiffer. All rights reserved.
//

import UIKit

class ClassesCollectionViewDataSource: NSObject, UICollectionViewDataSource {

    private var classController = TKClassController()
    var classes : [TKClass] = []
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return classes.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item != collectionView.numberOfItems(inSection: 0)-1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ClassCell
            cell?.className.text = classes[indexPath.item].name
           return cell!
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addCell", for: indexPath)
            return cell
        }
        
    }
}
