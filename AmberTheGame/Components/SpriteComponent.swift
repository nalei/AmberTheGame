import SpriteKit
import GameplayKit

class SpriteComponent: GKComponent {
  let node: SKSpriteNode
  
  init(texture: SKTexture, size: CGSize) {
    node = SKSpriteNode(texture: texture, color: .white, size: size)
    super.init()
    
    node.anchorPoint = CGPoint(x: 0.5, y: 0)
    
    let path = UIBezierPath(roundedRect: CGRect(x: -21, y: 3, width: 42, height: 64), cornerRadius: 0).cgPath
    let physicsBody = SKPhysicsBody(polygonFrom: path)
    
    physicsBody.categoryBitMask = ColliderType.PLAYER
    physicsBody.contactTestBitMask = ColliderType.GROUND
    physicsBody.isDynamic = true
    physicsBody.allowsRotation = false
    physicsBody.friction = 0
    physicsBody.restitution = 0
    physicsBody.mass = 0.15
    node.physicsBody = physicsBody
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func squashAndSretch(xScale: CGFloat, yScale: CGFloat) {
    node.xScale = xScale * node.xScale
    node.yScale = yScale
  }
  
  func isContactByGround() -> Bool {
    for body in node.physicsBody!.allContactedBodies() {
      if body.categoryBitMask == ColliderType.GROUND {
        return true
      }
    }
    return false
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
