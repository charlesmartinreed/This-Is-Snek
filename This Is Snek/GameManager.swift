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
    
    var playerDirection: Int = 3 //1 is left, 2 is up, 3 is right, 4 is down
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    func initGame() {
        //the starting player position
        scene.playerPositions.append((10, 10))
        scene.playerPositions.append((10, 11))
        scene.playerPositions.append((10, 12))
        renderChange()
    }
    
    func renderChange() {
        //this will be called every time we move the snek
        for (node, x, y) in scene.gameArray {
            if contains(a: scene.playerPositions, v: (x, y)) {
                node.fillColor = SKColor.cyan //these represent the snek's position on the board
            } else {
                node.fillColor = SKColor.clear //these blocks are nothing, clear means they'll reflect whatever color we set for the board, currently darkGray
            }
        }
    }
    
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
            }
        }
    }
    
    func swipe(ID: Int) {
        //if you're moving down, you can't immediately move up, etc.
        if !(ID == 2 && playerDirection == 4) && !(ID == 4 && playerDirection == 2) && !(ID == 1 && playerDirection == 3) && !(ID == 3 && playerDirection == 1) {
            playerDirection = ID
        }
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
            
            //MARK:- Make the snek wrap around the screen when it reaches the bounds
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
        
        renderChange()
    }
    
}
