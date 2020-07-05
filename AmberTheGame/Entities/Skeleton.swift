import SpriteKit
import GameplayKit

class Skeleton: Enemy {
  // MARK: - Initialization
  
  required override init() {
    super.init()
    
    let spriteComponent = SpriteComponent(texture: SKTexture(imageNamed: "skeleton-damage_6"), size: CGSize(width: 200, height: 200))
    addComponent(spriteComponent)
    
    let physicsComponent = PhysicsComponent(physicsBody: SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 90), center: CGPoint(x: -15, y: -15)))
    physicsComponent.physicsBody.categoryBitMask = CollisionCategory.ENEMY
    physicsComponent.physicsBody.collisionBitMask = CollisionCategory.GROUND
    physicsComponent.physicsBody.mass = 0.50
    physicsComponent.physicsBody.affectedByGravity = false
    addComponent(physicsComponent)

    // Связываем `PhysicsComponent` и `SpriteComponent`.
    spriteComponent.node.physicsBody = physicsComponent.physicsBody
    
    addComponent(AnimationComponent(
      idle: SKTexture(imageNamed: "skeleton-damage_6"),
      run: nil,
      jumpUp: nil,
      jumpMiddle: nil,
      jumpDown: nil,
      damage: SKAction(named: "skeleton-damage")
    ))
    
    let attackComponent = AttackComponent(hitBoxSize: CGSize(width: 50, height: 50), hurtBoxSize: CGSize(width: 40, height: 90))
    attackComponent.hurtBox.position = CGPoint(x: -15, y: -15)
    spriteComponent.node.addChild(attackComponent.hurtBox)
    addComponent(attackComponent)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
