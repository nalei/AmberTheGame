import SpriteKit
import GameplayKit

class Amber: GKEntity {
  init(camera: SKCameraNode, scene: SKScene, entityManager: EntityManager) {
    super.init()
    
    let spriteComponent = SpriteComponent(texture: SKTexture(imageNamed: "amber-idle"), size: CGSize(width: 100, height: 100))
    addComponent(spriteComponent)
    
    let path = UIBezierPath(roundedRect: CGRect(x: -21, y: 3, width: 42, height: 64), cornerRadius: 0).cgPath
    let physicsComponent = PhysicsComponent(physicsBody: SKPhysicsBody(polygonFrom: path))
    physicsComponent.physicsBody.categoryBitMask = CollisionCategory.PLAYER
    physicsComponent.physicsBody.collisionBitMask = CollisionCategory.GROUND
    physicsComponent.physicsBody.contactTestBitMask = CollisionCategory.GROUND
    physicsComponent.physicsBody.mass = 0.15
    addComponent(physicsComponent)
    
    /// Connect the `PhysicsComponent` and the `SpriteComponent`.
    spriteComponent.node.physicsBody = physicsComponent.physicsBody
    
    addComponent(PlayerControlComponent(camera: camera, scene: scene))
    
    addComponent(MovementComponent())
    
    addComponent(AnimationComponent(
      idle: SKTexture(imageNamed: "amber-idle"),
      run: SKAction(named: "amber-run"),
      jumpUp: SKTexture(imageNamed: "amber-jump-up"),
      jumpMiddle: SKTexture(imageNamed: "amber-jump-middle"),
      jumpDown: SKTexture(imageNamed: "amber-jump-down")
    ))
    
    addComponent(FlyComponent(
      maxSpeed: 0,
      maxAcceleration: 0,
      radius: Float(spriteComponent.node.size.width / 2),
      entityManager: entityManager
    ))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
