//
//  GameScene.swift
//  This Is Snek
//
//  Created by Charles Martin Reed on 12/12/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //MARK:- Properties
    var gameLogo: SKLabelNode!
    var bestScore: SKLabelNode!
    var playButton: SKShapeNode!
    var game: GameManager!
    
    override func didMove(to view: SKView) {
       initializeMenu()
        game = GameManager()
    }
    
    //MARK:- Menu creation method
    private func initializeMenu() {
        //create the game title
        gameLogo = SKLabelNode(fontNamed: "Futura-CondensedExtraBold")
        gameLogo.zPosition = 1
        gameLogo.position = CGPoint(x: 0, y: (size.height / 2) - 200)
        gameLogo.fontSize = 60
        gameLogo.text = "SNEK"
        gameLogo.fontColor = .red
        self.addChild(gameLogo)
        
        //create the best score
        bestScore = SKLabelNode(fontNamed: "Futura-Medium")
        bestScore.zPosition = 1
        bestScore.position = CGPoint(x: 0, y: gameLogo.position.y - 50)
        bestScore.fontSize = 40
        bestScore.fontColor = .white
        bestScore.text = "Best Score: 0"
        self.addChild(bestScore)
        
        //draw and display the play button
        //using SKShapeNodes here for ease of creation, but there are performance concerns - these are drawn once per frame.
        playButton = SKShapeNode()
        playButton.name = "play_button"
        playButton.zPosition = 1
        playButton.position = CGPoint(x: 0, y: (size.height / -2) + 200) //-2 puts it down toward the bottom of the screen
        playButton.fillColor = .cyan
        
        let topCorner = CGPoint(x: -50, y: 50)
        let bottomCorner = CGPoint(x: -50, y: -50)
        let middle = CGPoint(x: 50, y: 0)
        
        let path = CGMutablePath()
        path.addLine(to: topCorner)
        path.addLines(between: [topCorner, bottomCorner, middle])
        playButton.path = path
        
        self.addChild(playButton)
            
        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.nodes(at: location)
            for node in touchedNode {
                if node.name == "play_button" {
                    startGame()
                }
            }
        }
    }
    
    private func startGame() {
        //begin the round by removing the menu elements from the title screen
        gameLogo.run(SKAction.move(by: CGVector(dx: -50, dy: 600), duration: 0.5)) {
            self.gameLogo.isHidden = true
        }
        
        playButton.run(SKAction.scale(to: 0, duration: 0.3)) {
            self.playButton.isHidden = true
        }
        
        let bottomCorner = CGPoint(x: 0, y: (size.height / -2) + 30)
        bestScore.run(SKAction.move(to: bottomCorner, duration: 0.4))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
