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
    
    node.anchorPoint = CGPoint(x: 0.5, y: 0)
    
    let physicsBody = SKPhysicsBody(
      rectangleOf: CGSize(width: 64, height: 64),
      center: CGPoint(x: 0, y: 64 / 2)
    )
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

extension SKSpriteNode {
  func drawBorder(color: UIColor, width: CGFloat) {
    let shapeNode = SKShapeNode(rect: frame)
    shapeNode.fillColor = .clear
    shapeNode.strokeColor = color
    shapeNode.lineWidth = width
    addChild(shapeNode)
  }
}

