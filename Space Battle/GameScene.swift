//
//  GameScene.swift
//  Space Battle
//
//  Created by Chalu Jugo on 8/09/21.
//

import SpriteKit
import GameplayKit

var score = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    enum gameStatus {
        case before
        case during
        case after
    }
    
    var currentStatus = gameStatus.before
    let titleLabel = SKLabelNode(fontNamed: "Press Start 2P")
    let startLabel = SKLabelNode(fontNamed: "Press Start 2P")

    var levelNum = 0
    let scoreLabel = SKLabelNode(fontNamed: "Press Start 2P")
    
    var enemyInterval = 2.0
    
    var lives = 5
    var livesLabel = SKLabelNode(fontNamed: "Press Start 2P")
    
    let player = SKSpriteNode(imageNamed: "syringe")
    let bulletSound = SKAction.playSoundFileNamed("shoot.mp3", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("impact.wav", waitForCompletion: false)
    
    // physics categories for physics bodies to control interactions
    struct PhysicsCategories {
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1
        static let Bullet : UInt32 = 0b10
        static let Enemy : UInt32 = 0b100 // 4
        
    }
    
    // random numbers generated for spawning enemies
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    var gameArea: CGRect

    override init(size: CGSize) {
        // max aspect ratio used in our calcs
        let maxAspectRatio: CGFloat = 16.0/9.0
        // figure out our playable area
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        
        gameArea = CGRect(x: margin, y:0, width: playableWidth, height: size.height)
        super.init(size: size)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func didMove(to view: SKView) {
        score = 0
        self.physicsWorld.contactDelegate = self
        // Background
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        // Player
        player.setScale(4)
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
        player.zPosition = 2
        
        // making the physics body
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        
        // handling collisions with bullet
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        
        self.addChild(player)
        
        startNewLevel()
        
        scoreLabel.text = "SCORE: 0"
        scoreLabel.fontSize = 50
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.10, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "LIVES: 5"
        livesLabel.fontSize = 50
        livesLabel.fontColor = SKColor.white
        livesLabel.position = CGPoint(x: self.size.width * 0.80, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        

    
        titleLabel.text = "GET VAXXED"
        titleLabel.fontSize = 105
        titleLabel.fontColor = SKColor.yellow
        titleLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.57)
        titleLabel.zPosition = 100
        
        let scaleUpAction = SKAction.scale(to: 1.1, duration: 0.6)
        let scaleDownAction = SKAction.scale(to: 1, duration: 0.6)
        let scaleActionSequence = SKAction.sequence([scaleUpAction, scaleDownAction])
        let repeatScaleAction = SKAction.repeatForever(scaleActionSequence)
        titleLabel.run(repeatScaleAction)

        self.addChild(titleLabel)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
  

        startLabel.text = "TAP TO START"
        startLabel.fontSize = 55
        startLabel.fontColor = SKColor.white
        startLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.52)
        startLabel.zPosition = 100
        startLabel.alpha = 0
        self.addChild(startLabel)
        
        startLabel.run(fadeInAction)
        
        
    }
    
    func startGame() {
        currentStatus = gameStatus.during
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        startLabel.run(deleteSequence)
        titleLabel.run(deleteSequence)
        
        let movePlayerToScreenAction = SKAction.moveTo(y: self.size.height * 0.15, duration: 0.3)
        _ = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([movePlayerToScreenAction])
        player.run(startGameSequence)
        
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height * 0.95, duration: 0.3)

        scoreLabel.run(moveOnToScreenAction)
        livesLabel.run(moveOnToScreenAction)
        
    }
    
    func incrementScore() {
        score += 1
        scoreLabel.text = "SCORE: \(score)"
        if score == 15 || score == 25 || score == 35 || score == 50 {
            startNewLevel()
        }
    }
    
    func decrementLife() {
        lives -= 1
        livesLabel.text = "LIVES: \(lives)"
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        
        if lives == 0 {
            gameOver()
        }
        
    }
    
    func gameOver() {
        currentStatus = gameStatus.after
        
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Bullet"){
            bullet, stop in
            bullet.removeAllActions()
        }
        
        self.enumerateChildNodes(withName: "Enemy"){
            enemy, stop in
            enemy.removeAllActions()
        }
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitTime = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitTime, changeSceneAction])
        self.run(changeSceneSequence)
        
    }
    
    func changeScene() {
        
        let nextScene = GameOver(size: self.size)
        nextScene.scaleMode = self.scaleMode
        self.view!.presentScene(nextScene)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        
        else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy {
            // if enemy hits player
            
            if body1.node != nil {
                // use node! "force unwraps" meaning there is guaranteed to be a node here
                explosion(spawnPosition: body1.node!.position)
            }
            
            if body2.node != nil {
                explosion(spawnPosition: body2.node!.position)
            }
                // node? -> optional because these bodies might not have a node. eg. when 2 bullets hit the enemy at the same time (would cause a glitch if not optional)
                body1.node?.removeFromParent()
                body2.node?.removeFromParent()
                gameOver()

        }
        
        if(body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy){
            
            // check if node exists
            if(body2.node != nil) {
            // if bullet hits enemy

                if body2.node!.position.y  > self.size.height {
                    return
                } else {
                    
                    incrementScore()

                    explosion(spawnPosition: body2.node!.position)
                    body1.node?.removeFromParent()
                    body2.node?.removeFromParent()
                    
                }
            }
        }
    }
    
    func explosion(spawnPosition: CGPoint) {
        let explosion = SKSpriteNode(imageNamed: "explosion3")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(2)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 16, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        
        explosion.run(explosionSequence)
        
    }
    
    func fireBullet() {
        let bullet = SKSpriteNode(imageNamed: "fire 1")
        bullet.name = "Bullet"
        bullet.setScale(5)
        bullet.position = player.position
        bullet.zPosition = 1
        
        // making physics body
        bullet.physicsBody = SKPhysicsBody(rectangleOf:  bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        
        // handling collisions with enemy
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        
        
        self.addChild(bullet)
        
        // bullet actions
        let moveBullet = SKAction.moveTo(y:self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
    }
    
    func startNewLevel() {
        levelNum += 1
        enemyInterval -= 0.25
        
        if self.action(forKey: "spawningEnemies") != nil {
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNum {
        case 1: levelDuration = 1
        case 2: levelDuration = 0.8
        case 3: levelDuration = 0.6
        case 4: levelDuration = 0.5
        case 5: levelDuration = 0.35
        default:
            levelDuration = 0.5
            print("Cannot find level info")
        }
        let waitTime = SKAction.wait(forDuration: levelDuration)
        let spawn = SKAction.run(spawnEnemy)

        let spawnSequence = SKAction.sequence([waitTime,spawn])
        
        let spawnLoop = SKAction.repeatForever(spawnSequence)
        self.run(spawnLoop,withKey: "spawningEnemies")
    }
    
    func spawnEnemy() {
        let randomXStartpoint = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEndpoint = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startpoint = CGPoint(x: randomXStartpoint, y: self.size.height * 1.2)
        let endpoint = CGPoint(x: randomXEndpoint, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "covid")
        enemy.name = "Enemy"
        enemy.setScale(2.5)
        enemy.position = startpoint
        enemy.zPosition = 2
        
        // making physics body
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        
        // handling collisions with bullet
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endpoint, duration: TimeInterval(enemyInterval))
        let deleteEnemy = SKAction.removeFromParent()
        let loseLifeAction = SKAction.run(decrementLife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseLifeAction])
        if currentStatus == gameStatus.during {
            enemy.run(enemySequence)
        }
        
        let diffX = endpoint.x - startpoint.x
        let diffY = endpoint.y - startpoint.y
        
        let rotationAmount = atan2(diffY, diffX)
        enemy.zRotation = rotationAmount
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startGame()
        
        if currentStatus == gameStatus.during {
            fireBullet()
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            // How big of a gap where we were touching and we are touching now
            let distanceMoved = pointOfTouch.x - previousPointOfTouch.x
            
            if currentStatus == gameStatus.during {
                player.position.x += distanceMoved
            }
            
            // make sure ship does not leave playable area
            if player.position.x > gameArea.maxX  - player.size.width / 2{
                player.position.x = gameArea.maxX
            }
            
            if player.position.x < gameArea.minX - player.size.width / 2{
                player.position.x = gameArea.minX
            }
        }
    }
}
