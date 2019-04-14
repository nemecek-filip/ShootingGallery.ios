//
//  GameScene.swift
//  ShootingGallery
//
//  Created by Filip Němeček on 09/04/2019.
//  Copyright © 2019 Filip Němeček. All rights reserved.
//

import SpriteKit

enum ShootingRow : CGFloat, CaseIterable {
    case top = -200
    case middle = 0
    case bottom = 200
}

class GameScene: SKScene {
    
    let defaultFontSize: CGFloat = 28
    
    let defaultFontName = "GillSans-Bold"
    
    var scoreLabel: SKLabelNode!
    var reloadLabel: SKLabelNode!
    var timerLabel: SKLabelNode!
    var ammoLabel: SKLabelNode!
    
    var targets = [TargetNode]()
    
    var timeRemaining = 60 {
        didSet {
            timerLabel?.text = "\(timeRemaining)"
        }
    }
    
    var currentAmmo = 6 {
        didSet {
            ammoLabel?.text = "Ammo: \(currentAmmo)"
            colorizeAmmoLabel()
        }
    }
    
    var targetTimer: Timer!
    
    var gameTimer: Timer!
    
    func initLabels() {
        scoreLabel = SKLabelNode(fontNamed: defaultFontName)
        scoreLabel.fontSize = defaultFontSize
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: frame.minX, y: frame.maxY - scoreLabel.frame.height - 10)
        addChild(scoreLabel)
        
        reloadLabel = SKLabelNode(fontNamed: defaultFontName)
        reloadLabel.fontSize = defaultFontSize
        reloadLabel.text = "Reload"
        reloadLabel.name = "reload"
        reloadLabel.position = CGPoint(x: frame.minX + reloadLabel.frame.width / 2 + 10, y: frame.minY + 10)
        addChild(reloadLabel)
        
        timerLabel = SKLabelNode(fontNamed: defaultFontName)
        timerLabel.fontSize = 44
        timerLabel.text = "\(timeRemaining)"
        timerLabel.position = CGPoint(x: 0 - timerLabel.frame.width / 2, y: frame.maxY - timerLabel.frame.height - 10)
        addChild(timerLabel)
        
        ammoLabel = SKLabelNode(fontNamed: defaultFontName)
        ammoLabel.fontSize = defaultFontSize
        ammoLabel.text = "Ammo: 6"
        ammoLabel.position = CGPoint(x: frame.midX, y: frame.maxY - timerLabel.frame.height - ammoLabel.frame.height - 15)
        addChild(ammoLabel)
        
        let friendsLabel = SKLabelNode(fontNamed: defaultFontName)
        friendsLabel.fontSize = defaultFontSize
        friendsLabel.text = "Don't shoot: \(TargetNode.friendTypes.joined(separator: " "))"
        friendsLabel.position = CGPoint(x: frame.maxX - friendsLabel.frame.width / 2 - 10, y: frame.maxY - friendsLabel.frame.height / 2 - 15)
        addChild(friendsLabel)
    }
    
    func colorizeAmmoLabel() {
        let colorizeAction = SKAction.colorize(with: currentAmmo == 0 ? UIColor.red : UIColor.white, colorBlendFactor: 1, duration: 0.2)
        
        ammoLabel.run(colorizeAction)
    }
    
    func showGameOver() {
        let gameOver = SKLabelNode(fontNamed: defaultFontName)
        gameOver.text = "Game over!"
        gameOver.fontSize = 80
        gameOver.zPosition = 10
        gameOver.position = CGPoint(x: frame.midX - gameOver.frame.width / 2, y: frame.midY - gameOver.frame.height / 2)
        addChild(gameOver)
    }
    
    var score = 0 {
        didSet {
            scoreLabel?.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        initLabels()
       
        targetTimer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        targetTimer.tolerance = 0.1
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(gameTimerTick), userInfo: nil, repeats: true)
        gameTimer.tolerance = 0.1
    }
    
    @objc func gameTimerTick() {
        timeRemaining -= 1
        
        if timeRemaining <= 0 {
            targetTimer.invalidate()
            gameTimer.invalidate()
            print("Game over!")
            showGameOver()
        }
    }
    
    @objc func createEnemy() {
        let randomRow = ShootingRow.allCases.randomElement()!
        
        let startingPosition: CGPoint
        let endingPosition: CGPoint
        
        let randomY = randomRow.rawValue
        
        if randomRow == .middle {
            startingPosition = CGPoint(x: frame.maxX + 100, y: randomY)
            endingPosition = CGPoint(x: frame.minX - 300, y: randomY)
        } else {
            startingPosition = CGPoint(x: frame.minX - 100, y: randomY)
            endingPosition = CGPoint(x: frame.maxX + 300, y: randomY)
        }
        
        let target = TargetNode()
        target.position = startingPosition
        target.move(to: endingPosition)
        
        addChild(target)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard timeRemaining > 0 else { return }
        
        let tappedNodes = nodes(at: touch.location(in: self))
        
        if tappedNodes.contains(where: { (node) -> Bool in
            node.name == "reload"
        }) {
            currentAmmo = 6
            return
        }
        
        guard currentAmmo > 0 else { return }
        
        currentAmmo -= 1
        
        let tappedTargets = tappedNodes.compactMap { $0 as? TargetNode }
        
        guard let target = tappedTargets.first else { return }
        
        if target.isFriend {
            score -= 5
            
            showMagicEffect(at: target.position)
            
            scoreLabel.removeAllActions()
            
            flashRedScoreLabel()
            
            return
        }
        
        score += Int(target.scoreMultiplier * 1)
        
        showExplosion(at: target.position)
        
        target.run(SKAction.fadeOut(withDuration: 0.2))
        
    }
    
    func flashRedScoreLabel() {
        let colorize = SKAction.colorize(with: UIColor.red, colorBlendFactor: 1, duration: 0.1)
        let wait = SKAction.wait(forDuration: 0.2)
        let backToWhite = SKAction.colorize(with: UIColor.white, colorBlendFactor: 1, duration: 0.1)
        let redFlashSequence = SKAction.sequence([colorize, wait, backToWhite, colorize, wait, backToWhite])
        scoreLabel.run(redFlashSequence)
    }
    
    func showExplosion(at position: CGPoint) {
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = position
        addChild(explosion)
        explosion.run(waitAndRemoveAction)
    }
    
    func showMagicEffect(at position: CGPoint) {
        let magic = SKEmitterNode(fileNamed: "MagicEffect")!
        magic.position = position
        addChild(magic)
        magic.run(waitAndRemoveAction)
    }
    
    private var waitAndRemoveAction: SKAction {
        return SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.removeFromParent()])
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
