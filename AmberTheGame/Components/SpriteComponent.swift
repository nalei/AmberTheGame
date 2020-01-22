import SpriteKit
import GameplayKit

struct ColliderType {
  static let PLAYER: UInt32 = 1
  static let GROUND: UInt32 = 2
}

class SpriteComponent: GKComponent {
  let node: SKSpriteNode
  
  init(texture: SKTexture, size: CGSize) {
    node = SKSpriteNode(texture: texture, color: .white, size: size)
    super.init()
    
    let physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
    physicsBody.categoryBitMask = ColliderType.PLAYER
    physicsBody.affectedByGravity = true
    physicsBody.isDynamic = true
    physicsBody.allowsRotation = false
    physicsBody.restitution = 0.0
    node.physicsBody = physicsBody
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
