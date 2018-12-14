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
    
    //MARK:- Title screen roperties
    var gameLogo: SKLabelNode!
    var bestScore: SKLabelNode!
    var playButton: SKShapeNode!
    var game: GameManager!
    
    //MARK:- Game round properties
    var currentScore: SKLabelNode!
    var playerPositions: [(Int, Int)] = []
    var gameBG: SKShapeNode!
    var gameArray: [(node: SKShapeNode, x: Int, y: Int)] = []
    
    override func didMove(to view: SKView) {
       initializeMenu()
        game = GameManager(scene: self) //GameManager contains a reference to GameScene, once it is initialized
        
        initializeGameView()
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
    
    //MARK:- Game round logic
    private func initializeGameView() {
        currentScore = SKLabelNode(fontNamed: "Futura-Medium")
        currentScore.zPosition = 1
        currentScore.position = CGPoint(x: 0, y: (size.height / -2 ) + 60)
        currentScore.fontSize = 40
        currentScore.text = "Score: 0"
        currentScore.isHidden = true //hidden until we leave the menu
        currentScore.fontColor = SKColor.white
        
        addChild(currentScore)
        
        //setting up the stage background
        let width = 550
        let height = 1100
        let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
        gameBG = SKShapeNode(rect: rect, cornerRadius: 0.02)
        gameBG.fillColor = .darkGray
        gameBG.zPosition = 2
        gameBG.isHidden = true //hidden until we leave the menu
        
        addChild(gameBG)
        
        createGameBoard(width: width, height: height)
        
    }
    
    private func createGameBoard(width: Int, height: Int) {
        print("board is being created!")
        //initializes a bunch of square cells and adds them to the game board
        let cellWidth: CGFloat = 27.5
        let numRows = 40
        let numCols = 20
        var x = CGFloat(width / -2) + (cellWidth / 2)
        var y = CGFloat(height / 2) - (cellWidth / 2)
        
        //loop through rows and cols, place a cell there
        for i in 0..<numRows {
            for j in 0..<numCols {
                let cellNode = SKShapeNode(rectOf: CGSize(width: cellWidth, height: cellWidth))
                cellNode.strokeColor = .black
                cellNode.zPosition = 2
                cellNode.position = CGPoint(x: x, y: y)
                gameArray.append((node: cellNode, x: i, y: j)) //this is used to easily find a given cellNode in our game array by row and column
                gameBG.addChild(cellNode)
                
                x += cellWidth
            }
            //reset x, iterate y
            x = CGFloat(width / -2) + (cellWidth / 2)
            y -= cellWidth
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
        
        //start building the game stage UI
        let bottomCorner = CGPoint(x: 0, y: (size.height / -2) + 20)
        bestScore.run(SKAction.move(to: bottomCorner, duration: 0.4)) {
            self.gameBG.setScale(0)
            self.currentScore.setScale(0)
            self.gameBG.isHidden = false
            self.currentScore.isHidden = false
            self.gameBG.run(SKAction.scale(to: 1, duration: 0.4))
            self.currentScore.run(SKAction.scale(to: 1, duration: 0.4))
            
            self.game.initGame()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        game.update(time: currentTime)
    }
}
