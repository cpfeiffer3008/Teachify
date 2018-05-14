//
//  GameViewController.swift
//  Teachify
//
//  Created by Normen Krug on 08.04.18.
//  Copyright © 2018 Christian Pfeiffer. All rights reserved.
//

import UIKit
import SpriteKit

class MathPianoGameViewController: UIViewController {
    
    let skView: SKView = {
        let view = SKView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var currentGame: BasicScene!
    var scene: SKScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Game")
        
        NotificationCenter.default.addObserver(self, selector: #selector(exitGame), name: Notification.Name("exitGame"), object: nil)
    
        // Do any additional setup after loading the view.
        view.addSubview(skView)
        skView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        skView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        skView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        skView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scene = BasicScene(size: view.frame.size)
        skView.presentScene(scene)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func exitGame(){
        scene.removeFromParent()
        //switch to view 
    }
    
}
