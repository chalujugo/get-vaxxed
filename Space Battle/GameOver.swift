//
//  GameOver.swift
//  Space Battle
//
//  Created by Chalu Jugo on 8/10/21.
//

import Foundation
import SpriteKit


class GameOver: SKScene {
    
    let restartLabel = SKLabelNode(fontNamed: "Press Start 2P")

    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        let gameOverLabel = SKLabelNode(fontNamed: "Press Start 2P")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 130
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height * 0.70)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "Press Start 2P")
        scoreLabel.text = "FINAL SCORE: \(score)"
        scoreLabel.fontSize = 65
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height * 0.60)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        let defaults = UserDefaults()
        var highScore = defaults.integer(forKey: "highScoreSaved")
        if(score > highScore) {
            highScore = score
            defaults.set(highScore, forKey: "highScoreSaved")
        }
        
        let highScoreLabel = SKLabelNode(fontNamed: "Press Start 2P")
        highScoreLabel.text = "HIGH SCORE: \(highScore)"
        highScoreLabel.fontSize = 65
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height * 0.54)
        highScoreLabel.zPosition = 1
        self.addChild(highScoreLabel)
        
        let moveUpAction = SKAction.moveTo(y: self.size.height * 0.31, duration: 0.5)
        let moveDownAction = SKAction.moveTo(y: self.size.height * 0.30, duration: 0.5)
        let moveUpDownSequence = SKAction.sequence([moveUpAction, moveDownAction])
        let repeatMoveAction = SKAction.repeatForever(moveUpDownSequence)
        
        restartLabel.text = "PLAY AGAIN"
        restartLabel.fontSize = 60
        restartLabel.fontColor = SKColor.white
        restartLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height * 0.30)
        restartLabel.zPosition = 1
        self.addChild(restartLabel)
        restartLabel.run(repeatMoveAction)
        

        let reminderLabel = SKLabelNode(fontNamed: "Press Start 2P")
        reminderLabel.text = "ARM YOURSELF AGAINST COVID-19."
        reminderLabel.fontSize = 35
        reminderLabel.fontColor = SKColor.white
        reminderLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height * 0.18)
        reminderLabel.zPosition = 1
        self.addChild(reminderLabel)
        
        let scaleUpAction = SKAction.scale(to: 1.1, duration: 0.5)
        let scaleDownAction = SKAction.scale(to: 1, duration: 0.5)
        let scaleActionSequence = SKAction.sequence([scaleUpAction, scaleDownAction])
        let repeatScaleAction = SKAction.repeatForever(scaleActionSequence)
        
        let reminderLabel2 = SKLabelNode(fontNamed: "Press Start 2P")
        reminderLabel2.text = "GET VACCINATED TODAY."
        reminderLabel2.fontSize = 35
        reminderLabel2.fontColor = SKColor.yellow
        reminderLabel2.position = CGPoint(x: self.size.width*0.5, y: self.size.height * 0.15)
        reminderLabel2.zPosition = 1
        self.addChild(reminderLabel2)
        reminderLabel2.run(repeatScaleAction)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            if restartLabel.contains(pointOfTouch) {
                let nextScene = GameScene(size: self.size)
                nextScene.scaleMode = self.scaleMode
                self.view!.presentScene(nextScene)
            }
        }
    }
}
