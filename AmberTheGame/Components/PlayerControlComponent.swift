import GameplayKit
import SpriteKit

class PlayerControlComponent: GKComponent,  ControlInputSourceDelegate {
  var move: Bool = false
  var onGround: Bool = false
  
  var currentSpeed: CGFloat = 0
  var maxSpeed: CGFloat = 8
  var accel: CGFloat    = 1
  var facing: CGFloat   = 1
  
  var touchControlInputNode : TouchControlInputNode?
  
  init(camera: SKCameraNode, scene: SKScene) {
    super.init()
    
    touchControlInputNode = TouchControlInputNode(frame: scene.frame)
    touchControlInputNode?.inputDelegate = self
    touchControlInputNode?.position = CGPoint.zero
    camera.addChild(touchControlInputNode!)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func follow(command: String?) {
    switch command! {
    case "left":
      move = true
      facing = -1
    case "stop left":
      move = false
    case "right":
      move = true
      facing = 1
    case "stop right":
      move = false
    default:
      print("command: \(String(describing: command))")
    }
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
      return
    }
    
    if move {
      currentSpeed = maxSpeed * facing
    } else {
      currentSpeed = 0
    }
    
    spriteComponent.node.xScale = facing
    spriteComponent.node.position.x = spriteComponent.node.position.x + currentSpeed
  }
  
  func approach(start: CGFloat, end: CGFloat, shift: CGFloat) -> CGFloat {
    return start < end
      ? min(start + shift, end)
      : max(start - shift, end)
  }
}
