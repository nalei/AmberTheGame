import SpriteKit
import GameplayKit

class Bat: GKEntity {
  
  init(entityManager: EntityManager) {
    super.init()
    
    let texture = SKTexture(imageNamed: "bat-idle")
    
    let spriteComponent = SpriteComponent(texture: texture, size: CGSize(width: 65, height: 65))
    addComponent(spriteComponent)
    
    let path = UIBezierPath(roundedRect: CGRect(x: -19, y: -8, width: 42, height: 33), cornerRadius: 0).cgPath
    let physicsComponent = PhysicsComponent(physicsBody: SKPhysicsBody(polygonFrom: path))
    physicsComponent.physicsBody.categoryBitMask = CollisionCategory.ENEMY
    physicsComponent.physicsBody.collisionBitMask = CollisionCategory.GROUND
    physicsComponent.physicsBody.mass = 0.10
    physicsComponent.physicsBody.affectedByGravity = false
    addComponent(physicsComponent)
    
    // Connect the `PhysicsComponent` and the `SpriteComponent`.
    spriteComponent.node.physicsBody = physicsComponent.physicsBody
    spriteComponent.node.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    
    addComponent(FlyComponent(maxSpeed: 800, maxAcceleration: 40, radius: Float(texture.size().width * 0.3), entityManager: entityManager))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
