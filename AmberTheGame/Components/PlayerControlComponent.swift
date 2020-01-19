import GameplayKit
import SpriteKit

class PlayerControlComponent: GKComponent,  ControlInputSourceDelegate {
  var moveLeft  = false
  var moveRight = false
  
  var facing: CGFloat   = 1
  var maxSpeed: CGFloat = 8
  var speed: CGFloat    = 0
  var accel: CGFloat    = 1
  
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
      moveLeft = true
    case "stop left":
      moveLeft = false
    case "right":
      moveRight = true
    case "stop right":
      moveRight = false
    default:
      print("command: \(String(describing: command))")
    }
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
      return
    }
    
    if moveLeft {
      speed = -maxSpeed
    } else if moveRight {
      speed = maxSpeed
    } else {
      speed = 0
    }
    
    spriteComponent.node.position.x = spriteComponent.node.position.x + speed
  }
  
  func approach(start: CGFloat, end: CGFloat, shift: CGFloat) -> CGFloat {
    return start < end
    ? min(start + shift, end)
    : max(start - shift, end)
  }
}
