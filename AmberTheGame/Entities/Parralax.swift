import SpriteKit
import GameplayKit

class Parralax: GKEntity {
  
  init(camera: SKCameraNode, scene: SKScene, entityManager: EntityManager) {
    super.init()
    
    addComponent(SpriteComponent(texture: texture, size: CGSize(width: 100, height: 100)))
    
    addComponent(PlayerControlComponent(camera: camera, scene: scene))
    
    addComponent(MovementComponent())
    
    addComponent(AnimationComponent())
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
