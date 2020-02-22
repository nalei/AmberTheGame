import SpriteKit
import GameplayKit

class SpriteComponent: GKComponent {
  let node: SKSpriteNode
  
  init(texture: SKTexture, size: CGSize) {
    node = SKSpriteNode(texture: texture, color: .white, size: size)
    super.init()
    
    node.anchorPoint = CGPoint(x: 0.5, y: 0)
    
    let physicsBody = SKPhysicsBody(
      rectangleOf: CGSize(width: 42, height: 64),
      center: CGPoint(x: 0, y: 64 / 2)
    )
    
    physicsBody.categoryBitMask = ColliderType.PLAYER
    physicsBody.contactTestBitMask = ColliderType.GROUND
    physicsBody.affectedByGravity = true
    physicsBody.isDynamic = true
    physicsBody.allowsRotation = false
    physicsBody.friction = 0
    physicsBody.restitution = 0.1
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
}

//extension SKSpriteNode {
//  func drawBorder(color: UIColor, width: CGFloat) {
//    let shapeNode = SKShapeNode(rect: frame)
//    shapeNode.fillColor = .clear
//    shapeNode.strokeColor = color
//    shapeNode.lineWidth = width
//    addChild(shapeNode)
//  }
//}

