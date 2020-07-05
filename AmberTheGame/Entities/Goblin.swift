import SpriteKit
import GameplayKit

class Goblin: Enemy {
  // MARK: - Initialization
  
  required override init() {
    super.init()
    
    let spriteComponent = SpriteComponent(texture: SKTexture(imageNamed: "goblin-idle"), size: CGSize(width: 100, height: 100))
    spriteComponent.node.anchorPoint = CGPoint(x: 0.5, y: 0)
    addComponent(spriteComponent)
    
    let physicsComponent = PhysicsComponent(physicsBody: SKPhysicsBody(rectangleOf: CGSize(width: 42, height: 50), center: CGPoint(x: 0, y: 25)))
    physicsComponent.physicsBody.categoryBitMask = CollisionCategory.ENEMY
    physicsComponent.physicsBody.collisionBitMask = CollisionCategory.GROUND
    physicsComponent.physicsBody.contactTestBitMask = CollisionCategory.GROUND
    physicsComponent.physicsBody.mass = 0.20
//    physicsComponent.physicsBody.affectedByGravity = false
    addComponent(physicsComponent)
    
    // Связываем `PhysicsComponent` и `SpriteComponent`.
    spriteComponent.node.physicsBody = physicsComponent.physicsBody
    
    addComponent(MovementComponent(walkSpeed: 100, maxJump: 150, accel: 300, decel: 300))
    
    addComponent(AnimationComponent(
      idle: SKTexture(imageNamed: "goblin-idle"),
      run: SKAction(named: "goblin-run"),
      jumpUp: nil,
      jumpMiddle: nil,
      jumpDown: nil,
      damage: nil
    ))
    
    let agent = AgentComponent()
    agent.delegate = self
    agent.maxSpeed = 200
    agent.maxAcceleration = 300
    agent.mass = 0.03
    agent.radius = 35
    agent.behavior = GKBehavior()
    self.agentOffset = CGPoint(x: 0, y: 25)
    addComponent(agent)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
