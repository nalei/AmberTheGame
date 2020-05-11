import SpriteKit
import GameplayKit

class Goblin: GKEntity {
  
  init(entityManager: EntityManager) {
    super.init()
    
    let texture = SKTexture(imageNamed: "goblin-idle")
    
    let spriteComponent = SpriteComponent(texture: texture, size: CGSize(width: 100, height: 100))
    addComponent(spriteComponent)
    
    let path = UIBezierPath(roundedRect: CGRect(x: -21, y: 3, width: 42, height: 50), cornerRadius: 0).cgPath
    let physicsComponent = PhysicsComponent(physicsBody: SKPhysicsBody(polygonFrom: path))
    physicsComponent.physicsBody.categoryBitMask = CollisionCategory.ENEMY
    physicsComponent.physicsBody.collisionBitMask = CollisionCategory.GROUND
    physicsComponent.physicsBody.contactTestBitMask = CollisionCategory.GROUND
    physicsComponent.physicsBody.mass = 0.10
    addComponent(physicsComponent)
    
    // Connect the `PhysicsComponent` and the `SpriteComponent`.
    spriteComponent.node.physicsBody = physicsComponent.physicsBody
    
    addComponent(MovementComponent(walkSpeed: 300, maxJump: 150, accel: 300, decel: 300))
    
    addComponent(AnimationComponent(
      idle: SKTexture(imageNamed: "goblin-idle"),
      run: SKAction(named: "goblin-run"),
      jumpUp: nil,
      jumpMiddle: nil,
      jumpDown: nil
    ))
    
    //addComponent(EnemyMoveComponent(maxSpeed: 1200, maxAcceleration: 40, radius: Float(texture.size().width * 0.3), entityManager: entityManager))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
