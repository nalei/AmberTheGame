import SpriteKit
import GameplayKit

class Goblin: GKEntity {
  
  init(entityManager: EntityManager) {
    super.init()
    
    let texture = SKTexture(imageNamed: "goblin-idle")
    
    let spriteComponent = SpriteComponent(texture: texture, size: CGSize(width: 100, height: 100))
    addComponent(spriteComponent)
    
    let path = UIBezierPath(roundedRect: CGRect(x: -21, y: 3, width: 42, height: 64), cornerRadius: 0).cgPath
    let physicsComponent = PhysicsComponent(physicsBody: SKPhysicsBody(polygonFrom: path))
    physicsComponent.physicsBody.categoryBitMask = CollisionCategory.ENEMY.rawValue
    physicsComponent.physicsBody.contactTestBitMask = CollisionCategory.GROUND.rawValue
    physicsComponent.physicsBody.mass = 0.15
    addComponent(physicsComponent)
    
    // Connect the `PhysicsComponent` and the `SpriteComponent`.
    spriteComponent.node.physicsBody = physicsComponent.physicsBody
    
    addComponent(MovementComponent())
    
    addComponent(AnimationComponent())
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
