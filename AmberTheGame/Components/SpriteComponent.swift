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
  
  func squashAndSretch(xScale: CGFloat, yScale: CGFloat) {
    node.xScale = xScale * node.xScale
    node.yScale = yScale
  }
  
  override func didAddToEntity() {
    node.entity = entity
  }

  override func willRemoveFromEntity() {
    node.entity = nil
  }
}
