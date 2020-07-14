import SpriteKit
import GameplayKit

class Skeleton: Enemy {
  // MARK: - Initialization
  
  required override init() {
    super.init()
    
    let spriteComponent = SpriteComponent(texture: SKTexture(imageNamed: "skeleton-idle"), size: CGSize(width: 200, height: 200))
    spriteComponent.node.anchorPoint = CGPoint(x: 0.5, y: 0.18)
    addComponent(spriteComponent)
    
    let physicsComponent = PhysicsComponent(physicsBody: SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 90), center: CGPoint(x: -15, y: 45)))
    physicsComponent.physicsBody.categoryBitMask = CollisionCategory.ENEMY
    physicsComponent.physicsBody.collisionBitMask = CollisionCategory.GROUND
    physicsComponent.physicsBody.contactTestBitMask = CollisionCategory.GROUND
    physicsComponent.physicsBody.fieldBitMask = 0
    physicsComponent.physicsBody.mass = 0.50
    addComponent(physicsComponent)

    // Связываем `PhysicsComponent` и `SpriteComponent`.
    spriteComponent.node.physicsBody = physicsComponent.physicsBody
    
    addComponent(MovementComponent())
    
    addComponent(AnimationComponent(
      idle: SKTexture(imageNamed: "skeleton-idle"),
      run: nil,
      jumpUp: nil,
      jumpMiddle: nil,
      jumpDown: nil,
      hit: nil,
      damage: SKAction(named: "skeleton-damage")
    ))
    
    let attackComponent = AttackComponent()
    attackComponent.hitBox.position = CGPoint(x: 60, y: 30)
    attackComponent.hitBox.size = CGSize(width: 50, height: 50)
    attackComponent.hurtBox.position = CGPoint(x: -15, y: 45)
    attackComponent.hurtBox.size = CGSize(width: 40, height: 90)
    spriteComponent.node.addChild(attackComponent.hurtBox)
    addComponent(attackComponent)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
