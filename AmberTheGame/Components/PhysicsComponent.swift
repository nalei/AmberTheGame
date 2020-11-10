import SpriteKit
import GameplayKit

class PhysicsComponent: GKComponent {
  var physicsBody: SKPhysicsBody
  
  init(physicsBody: SKPhysicsBody, colliderType: ColliderType) {
    self.physicsBody = physicsBody
    
    self.physicsBody.isDynamic = true
    self.physicsBody.allowsRotation = false
    self.physicsBody.friction = 0
    self.physicsBody.restitution = 0
    
    
    self.physicsBody.categoryBitMask = colliderType.categoryMask
    self.physicsBody.collisionBitMask = colliderType.collisionMask
    self.physicsBody.contactTestBitMask = colliderType.contactMask
    
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func isContactByGround() -> Bool {
    for body in physicsBody.allContactedBodies() {
      if body.categoryBitMask == ColliderType.GROUND.rawValue {
        return true
      }
    }
    return false
  }
}
