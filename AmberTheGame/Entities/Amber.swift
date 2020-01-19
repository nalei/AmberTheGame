import SpriteKit
import GameplayKit

class Amber: GKEntity {
  init(camera: SKCameraNode, scene: SKScene, entityManager: EntityManager) {
    super.init()
    let texture = SKTexture(imageNamed: "amber-idle")
    addComponent(SpriteComponent(texture: texture, size: CGSize(width: 100, height: 100)))
    addComponent(PlayerControlComponent(camera: camera, scene: scene))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
