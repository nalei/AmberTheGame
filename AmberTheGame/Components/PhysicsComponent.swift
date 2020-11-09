import SpriteKit
import GameplayKit

class PhysicsComponent: GKComponent {
  var physicsBody: SKPhysicsBody
  
  init(physicsBody: SKPhysicsBody) {
    physicsBody.isDynamic = true
    physicsBody.allowsRotation = false
    physicsBody.friction = 0
    physicsBody.restitution = 0
    self.physicsBody = physicsBody
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func isContactByGround() -> Bool {
    for body in physicsBody.allContactedBodies() {
      if body.categoryBitMask == ColliderType.GROUND {
        return true
      }
    }
    return false
  }
}
