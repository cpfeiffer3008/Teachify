//
//  GameCollectionDataSource.swift
//  Teachify
//
//  Created by Christian Pfeiffer on 12.04.18.
//  Copyright © 2018 Christian Pfeiffer. All rights reserved.
//

import UIKit

class GameCollectionDataSource: NSObject,UICollectionViewDataSource {
    let studentController : StudentModelController = StudentModelController()
    let tkFetchController : TKFetchController = TKFetchController()
    
    var ContiniousMode = false

    override init(){

    }
    
    func setContinousMode(isContinous : Bool){
        ContiniousMode = isContinous
    }
    
    // TODO: SectionHeader not working
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        if (ContiniousMode){
//            return 1
//        }
//        else {
//            if studentController.isMyClassSet(){
//                return studentController.getMyClass().subjects.count
//                }
//            }
//
//        return 0
//    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (ContiniousMode){
            return studentController.getContinousGameCount()
        }
        else {
            return tkFetchController.getSubjectCount()
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! GameCardCell
        var tlc = collectionView.window?.rootViewController as! UIViewController
        tlc = UIWindow.getVisibleViewControllerFrom(vc: tlc)
        
        if ContiniousMode {
            let myGame = studentController.getContinousGame(index: indexPath.row)
            cell.card.backgroundColor = myGame.color
            cell.card.icon = myGame.backgroundImage
            cell.card.title = myGame.name
            cell.card.itemTitle = "Endlosspiel"
            cell.card.itemSubtitle = "Subtitle?"
            cell.card.buttonText = "Spielen"
            cell.card.textColor = UIColor.white
            
            cell.setContiniousGame(game: myGame.type)
        }
        else{
                let tempSubject : TKSubject = tkFetchController.getSubjects()[indexPath.item]
                let tempDoc = tempSubject.documents[indexPath.row]
            
                cell.card.backgroundColor = tempSubject.color.color
                cell.card.icon = UIImage(named: "calculator")
                cell.card.title = tempDoc.name
                cell.card.itemTitle = tempSubject.name
                cell.card.itemSubtitle = "Anzahl Übungen: \(tempDoc.exercises.count)"
                cell.card.buttonText = "Spielen"
                cell.card.textColor = UIColor.white
                
//                cell.setExercises(newExercises: tempDoc.subjects[indexPath.item].documents[indexPath.row].exercises)
        }
        
        
        cell.card.hasParallax = true
        cell.card.action
        
        let cardContentVC = tlc.storyboard!.instantiateViewController(withIdentifier: "CardContent")
        cell.card.shouldPresent(cardContentVC, from: tlc, fullscreen: false)
        
        cell.view.addSubview(cell.card)
        return cell
    }
    
    // TODO: SectionHeader not working
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//
//        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "GameCardCellHeader", for: indexPath) as? SectionHeader{
//
//            if (ContiniousMode){
//                sectionHeader.SectionTitleLabel.text = ""
//            }
//            else {
//                if studentController.isMyClassSet() {
//                    sectionHeader.SectionTitleLabel.text = studentController.getMyClass().subjects[indexPath.item].name
//                }
//            }
//
//        }
//        return UICollectionReusableView()
//    }
}

extension UIWindow {


    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController  = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: rootViewController)
            
}
        return nil
    }

    class func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {

        if vc.isKind(of: UINavigationController.self) {

            let navigationController = vc as! UINavigationController
            return UIWindow.getVisibleViewControllerFrom(vc: navigationController.visibleViewController!)

        } else if vc.isKind(of: UITabBarController.self) {

            let tabBarController = vc as! UITabBarController
            return UIWindow.getVisibleViewControllerFrom(vc: tabBarController.selectedViewController!)

        } else {

            if let presentedViewController = vc.presentedViewController {

                return UIWindow.getVisibleViewControllerFrom(vc: presentedViewController)

            } else {

                return vc;
           }
        }
    }
}
