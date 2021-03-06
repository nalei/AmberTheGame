import GameplayKit
import SpriteKit

class ParallaxComponent: GKComponent {
  // MARK: - Properties
  
  var camera: SKCameraNode?
  var previousPosition: CGPoint?
  var dX: CGFloat = 1.1
  var dY: CGFloat = 1.2
  
  /// The `GKSKNodeComponent` for this component's entity.
  var spriteComponent: GKSKNodeComponent {
    guard let spriteComponent = entity?.component(ofType: GKSKNodeComponent.self) else {
      fatalError("A ParallaxComponent's entity must have a GKSKNodeComponent")
    }
    return spriteComponent
  }
  
  
  // MARK: - Initializers
  
  init(layer: Int, camera: SKCameraNode?) {
    super.init()
    self.camera = camera
    self.previousPosition = camera?.position
    
    switch layer {
    case 1:
      dX = 15
      dY = 5
    case 2:
      dX = 10
      dY = 4
    case 3:
      dX = 5
      dY = 2
    case 4:
      dX = 2
      dY = 1.9
    case 5:
      dX = 1.7
      dY = 1.5
    case 6:
      dX = 1.3
      dY = 1.25
    case 7:
      dX = 1.05
      dY = 1.1
    default:
      print("not valid layer value")
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
    // MARK: - GKComponent Life Cycle
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    let difX = ((camera?.position.x)! - (previousPosition?.x)!) / dX
    let difY = ((camera?.position.y)! - (previousPosition?.y)!) / dY
    
    spriteComponent.node.position = CGPoint(x: spriteComponent.node.position.x + difX, y: spriteComponent.node.position.y + difY)
    previousPosition = camera?.position
  }
}
