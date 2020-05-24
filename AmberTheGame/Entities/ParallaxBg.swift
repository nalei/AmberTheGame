import SpriteKit
import GameplayKit

class ParallaxBg: GKEntity {
  var layer: Int = 1
  
  init(spriteNode: SKSpriteNode, camera: SKCameraNode?) {
    super.init()
    
    guard let texture = spriteNode.texture else { return }
    
    if texture.description.contains("clouds") {
      layer = 7
    } else if texture.description.contains("sea") {
      layer = 6
    }
    
    addComponent(GKSKNodeComponent(node: spriteNode))
    
    addComponent(ParallaxComponent(layer: layer, camera: camera))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
