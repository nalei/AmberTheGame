import SpriteKit
import GameplayKit

class ParallaxBg: GKEntity {
  
  init(spriteNode: SKSpriteNode) {
    super.init()
    
    guard let texture = spriteNode.texture else { return }
    
    addComponent(GKSKNodeComponent(node: spriteNode))
    
    let parallaxComponent = ParallaxComponent()
    if texture.description.contains("clouds") {
      parallaxComponent.layer = 7
    } else if texture.description.contains("sea") {
      parallaxComponent.layer = 6
    }
    addComponent(parallaxComponent)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
