//
//  ResultScene.swift
//  Teachify
//
//  Created by Normen Krug on 16.04.18.
//  Copyright © 2018 Christian Pfeiffer. All rights reserved.
//

import Foundation
import SpriteKit

class ResultScene: SKScene, BasicButtonDelegate{
    
    var playButton: BasicButton!
    var returnButton: BasicButton!
    let playButtonText = "Play again"
    let returnButtonText = "Return"
    var winner: Bool!
    var highscore: Int?
    var highscoreLabel: SKLabelNode!
    var score: SKLabelNode!
    
    
    override func didMove(to view: SKView) {
        playButton = BasicButton(texture: nil, color: UIColor.green, size: CGSize(width: 250, height: 75),fontColor: UIColor.black, text: playButtonText)
        playButton.delegate = self
        playButton.isUserInteractionEnabled = true
        playButton.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - 100)
        
        returnButton = BasicButton(texture: nil, color: UIColor.red, size: CGSize(width: 250, height: 75), fontColor: UIColor.black, text: returnButtonText)
        setupScore()
        returnButton.delegate = self
        returnButton.isUserInteractionEnabled = true
        returnButton.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - 150 - playButton.size.height)
        
        addChild(returnButton)
        addChild(playButton)
    }
    
    fileprivate func setupScore() {
        score = SKLabelNode(text:"Highscore: \(String(highscore!))")
        score.position = CGPoint(x: self.frame.width / 2,y: self.frame.height / 2)
        score.fontName = "AvenirNext-Bold"
        score.fontSize = 45
        addChild(score)
    }
    
    func basicButtonPressed(_ button: BasicButton) {
        switch button.label.text {
        case playButtonText:
            let basic = BasicScene(size: self.size)
            let transition = SKTransition.flipVertical(withDuration: 1.0)
            self.scene!.view?.presentScene(basic, transition: transition)
        case returnButtonText:
            let nc = NotificationCenter.default
            nc.post(name: NSNotification.Name("exitGame"), object: nil)
        default:
            return
        }
       
        
    }
    
    
    
}
