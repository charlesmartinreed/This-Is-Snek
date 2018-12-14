//
//  GameManager.swift
//  This Is Snek
//
//  Created by Charles Martin Reed on 12/12/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import SpriteKit

//this will hold score data and manage the movement of the player
class GameManager {
    
    var scene: GameScene! //we'll use this to track the location of the snek
    var nextTime: Double? //time of the next event
    var timeExtension: Double = 0.15 //how long between events
    
    var playerDirection: Int = 4 //1 is left, 2 is up, 3 is right, 4 is down
    var currentScore: Int = 0
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    func initGame() {
        //the starting player position
        scene.playerPositions.append((10, 10))
        scene.playerPositions.append((10, 11))
        scene.playerPositions.append((10, 12))
        renderChange()
        generateNewPoint()
    }
    
    func renderChange() {
        //this will be called every time we move the snek
        for (node, x, y) in scene.gameArray {
            if contains(a: scene.playerPositions, v: (x, y)) {
                node.fillColor = SKColor.cyan //these represent the snek's position on the board
            } else {
                node.fillColor = SKColor.clear //these blocks are nothing, clear means they'll reflect whatever color we set for the board, currently darkGray
                
                if scene.scorePos != nil {
                    //if the node position == randomly placed score...
                    //positions are flipped in the nodes array, so we're comparing x to y
                    if Int((scene.scorePos?.x)!) == y && Int((scene.scorePos?.y)!) == x {
                        node.fillColor = .red
                    }
                }
            }
        }
    }
    
    //MARK:- Scoring logic
    private func checkForScore() {
        if scene.scorePos != nil {
            let x = scene.playerPositions[0].0
            let y = scene.playerPositions[0].1
            
            if Int((scene.scorePos?.x)!) == y && Int((scene.scorePos?.y)!) == x {
                currentScore += 1
                scene.currentScore.text = "Score: \(currentScore)"
                generateNewPoint()
                
                //extend the snake
                scene.playerPositions.append(scene.playerPositions.last!)
                scene.playerPositions.append(scene.playerPositions.last!)
                scene.playerPositions.append(scene.playerPositions.last!)
            }
        }
    }
    
    private func generateNewPoint() {
        var randomX = CGFloat(arc4random_uniform(UInt32(19))) //max x value is 20
        var randomY = CGFloat(arc4random_uniform(UInt32(39))) //max y value is 40
        
        //if the random point is inside of the snake, get a new point
        while contains(a: scene.playerPositions, v: (Int(randomX), Int(randomY))) {
            randomX = CGFloat(arc4random_uniform(UInt32(19)))
            randomY = CGFloat(arc4random_uniform(UInt32(39)))
        }
        
        scene.scorePos = CGPoint(x: randomX, y: randomY)
    }
    
    //MARK:- Game over logic
    private func checkForDeath() {
        if scene.playerPositions.count > 0 {
            var arrayOfPositions = scene.playerPositions
            let headOfSnake = arrayOfPositions[0] //cut the body off, leave head
            arrayOfPositions.remove(at: 0) //cut the head off, leave body
            
            //if head collides with body
            if contains(a: arrayOfPositions, v: headOfSnake){
                playerDirection = 0
            }
        }
    }
    
    private func finishAnimation() {
        if playerDirection == 0 && scene.playerPositions.count > 0 {
            var hasFinished = true
            
            let headOfSnake = scene.playerPositions[0]
            for position in scene.playerPositions { //check whether or not the snake has crossed itself as indicated by it shrinking down to one square
                if headOfSnake != position {
                    hasFinished = false
                }
            }
            
            if hasFinished {
                print("End game")
                playerDirection = 4
                scene.scorePos = nil
                scene.playerPositions.removeAll()
                renderChange()
                
                //return to menu
                scene.currentScore.run(SKAction.scale(to: 0, duration: 0.4)) {
                    self.scene.gameBG.isHidden = true
                    self.scene.gameLogo.isHidden = false
                    self.scene.gameLogo.run(SKAction.move(to: CGPoint(x: 0, y: (self.scene.frame.size.height / 2) - 200), duration: 0.5)) {
                        self.scene.playButton.isHidden = false
                        self.scene.playButton.run(SKAction.scale(to: 1, duration: 0.3))
                        self.scene.bestScore.run(SKAction.move(to: CGPoint(x: 0, y: self.scene.gameLogo.position.y - 50), duration: 0.3))
                    }
                    
                }
            }
        }
    }
    
    //MARK:- Game state checking logic
    func contains(a: [(Int, Int)], v: (Int, Int)) -> Bool {
        //check whether the tuple exists within an array of tuples
        let (c1, c2) = v
        for (v1, v2) in a {
            if v1 == c1 && v2 == c2 { return true }
        }
        return false
    }
    
    func update(time: Double) {
        //purpose of this code is to update the player position once per second only
        if nextTime == nil {
            nextTime = time + timeExtension
        } else {
            if time >= nextTime! {
                nextTime = time + timeExtension
                //print(time)
                updatePlayerPosition()
                checkForScore()
                checkForDeath()
                finishAnimation()
            }
        }
    }
    
    func swipe(ID: Int) {
        //if you're moving down, you can't immediately move up, etc.
        if !(ID == 2 && playerDirection == 4) && !(ID == 4 && playerDirection == 2) && !(ID == 1 && playerDirection == 3) && !(ID == 3 && playerDirection == 1) {
                if playerDirection != 0 { //if game not over
                    playerDirection = ID
            }
        }
        //print(playerDirection)
    }
    
    private func updatePlayerPosition() {
        var xChange = -1
        var yChange = 0
        
        switch playerDirection {
        case 1:
            //left
            xChange = -1
            yChange = 0
            break
        case 2:
            //up
            xChange = 0
            yChange = -1
            break
        case 3:
            //right
            xChange = 1
            yChange = 0
            break
        case 4:
            //down
            xChange = 0
            yChange = 1
            break
        case 0:
            //dead - stop moving
            xChange = 0
            yChange = 0
            break
        default:
            break
        }
        
        if scene.playerPositions.count > 0 {
            var start = scene.playerPositions.count - 1
            while start > 0 {
                scene.playerPositions[start] = scene.playerPositions[start - 1]
                start -= 1
            }
            //move front of snek in appropriate direction and then move tail blocks forward to next position
            scene.playerPositions[0] =  (scene.playerPositions[0].0 + yChange, scene.playerPositions[0].1 + xChange)
            
            //Make the snek wrap around the screen when it reaches the bounds
            let x = scene.playerPositions[0].1
            let y = scene.playerPositions[0].0
            
            if y > 40 {
                scene.playerPositions[0].0 = 0
            } else if y < 0 {
                scene.playerPositions[0].0 = 40
            } else if x > 20 {
                scene.playerPositions[0].1 = 0
            } else if x < 0 {
                scene.playerPositions[0].1 = 20
            }
        }
        
        //print(scene.playerPositions)
        renderChange()
    }
    
}
