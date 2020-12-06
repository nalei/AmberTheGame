import SpriteKit
import GameplayKit

class SpriteComponent: GKComponent {
  let node: SKSpriteNode
  
  init(texture: SKTexture, size: CGSize) {
    node = SKSpriteNode(texture: texture, color: .white, size: size)
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func squashAndSretch(xScale: CGFloat, yScale: CGFloat) {
    node.xScale = xScale * node.xScale
    node.yScale = yScale
  }
  
  public func bounceBack(force: CGFloat) {
    node.physicsBody?.applyImpulse(CGVector(dx: (-node.xScale * force), dy: 0.0))
  }
  
  override func didAddToEntity() {
    node.entity = entity
  }

  override func willRemoveFromEntity() {
    node.entity = nil
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
