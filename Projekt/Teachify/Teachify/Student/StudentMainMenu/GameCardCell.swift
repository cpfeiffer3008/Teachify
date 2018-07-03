//
//  GameCardCell.swift
//  Teachify
//
//  Created by Christian Pfeiffer on 12.04.18.
//  Copyright © 2018 Christian Pfeiffer. All rights reserved.
//

import UIKit
import Cards

class GameCardCell: UICollectionViewCell {
    let card = CardHighlight(frame: CGRect(x: 0, y: 0, width: 600 , height: 400))
    let gamectrl : GameController = GameController()
    var myExercises : [TKExercise]? = nil
    var isContinousCell : Bool?
    
    @IBOutlet weak var view: CardHighlight!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        card.delegate = self
    }
    
    func setContiniousGame(game : TKExerciseType){
        let myExercise = TKExercise(name: "Continous Play \(game.name)", deadline: nil, type: game, data: "")
        myExercises = []
        myExercises?.append(myExercise)
        isContinousCell = true
        print("GameCell: \(myExercises?.first?.name) isContinous: \(isContinousCell)")
    }
    
    func setExercises(newExercises :[TKExercise]){
        myExercises = []
        myExercises = newExercises
        isContinousCell = false
        print("GameCell: \(myExercises?.first?.name) isContinous: \(isContinousCell)")
    }
    
}

extension GameCardCell: CardDelegate {
    
    func cardDidTapInside(card: Card) {
        print("i got Tapped inside")
    }
    
    func cardHighlightDidTapButton(card: CardHighlight, button: UIButton) {
        var myExerciseDict :[Int : TKExercise] = [:]
        print("My Button got Tapped")
        print("storing Exercises")
        if let exercises = myExercises {
            print("storing Exercises sucessfully")
            for (index, element) in (myExercises?.enumerated())! {
                myExerciseDict[index] = element
            }
            gamectrl.setExercisesForGame(game: (myExerciseDict[0]?.type)!, exercises: myExercises!)
        }
        else {
            print("There were no Exercises set!")
        }
            NotificationCenter.default.post(name: .launchGame, object: nil, userInfo: myExerciseDict)
        }
    
    func cardIsShowingDetail(card: Card) {
        print("Card is showing Detail")
        
        if let selectedExercises = myExercises {
        let exerciseDict :[Int : [TKExercise]] = [0:selectedExercises]
            NotificationCenter.default.post(name: .exerciseSelected, object: nil, userInfo: exerciseDict)
        }
    }
}

