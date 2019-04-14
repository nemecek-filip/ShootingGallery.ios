//
//  TargetNode.swift
//  ShootingGallery
//
//  Created by Filip Němeček on 09/04/2019.
//  Copyright © 2019 Filip Němeček. All rights reserved.
//

import SpriteKit

enum TargetSize: CGFloat, CaseIterable {
    case mini = 0.6
    case normal = 1
    case big = 1.2
}

class TargetNode: SKLabelNode {

    let isFriend: Bool
    
    private let baseSize: CGFloat = 80
    
    let scoreMultiplier: CGFloat
    
    static let enemyTypes = ["👾", "🤖", "☠️", "👹", "👽", "🎃"]    
    static let friendTypes = ["🧚‍♀️", "👻"]
    
    private static var thirtyPercentChance: Bool {
        return Int.random(in: 0..<3) < 1
    }
    
    override init() {
        let targetSize = TargetSize.allCases.randomElement()!
        
        switch targetSize {
        case .mini:
            scoreMultiplier = 3
        case .big:
            scoreMultiplier = 1
        default:
            scoreMultiplier = 2
        }
        
        isFriend = TargetNode.thirtyPercentChance
        
        super.init()
        
        if isFriend {
            text = TargetNode.friendTypes.randomElement()
        } else {
            text = TargetNode.enemyTypes.randomElement()
        }
        
        fontSize = baseSize * targetSize.rawValue
    }
    
    func move(to position: CGPoint) {
        let moveAction = SKAction.move(to: position, duration: Double.random(in: 3...7.5))
        let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
        
        run(moveSequence)
    }
    
    func isOutOfBounds(of view: SKView) -> Bool {
        return position.x > view.frame.maxX + 200 || position.x < view.frame.minX + 200
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
}
