import SpriteKit
import GameplayKit

class InputComponent: GKComponent, ControlInputSourceDelegate {
  var touchControlInputNode : TouchControlInputNode?
  
  init(camera: SKCameraNode?, scene: SKScene) {
    super.init()
    
    touchControlInputNode = TouchControlInputNode(frame: scene.frame)
    touchControlInputNode?.inputDelegate = self
    touchControlInputNode?.position = CGPoint.zero
    
    camera?.addChild(touchControlInputNode!)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func follow(command: String?) {
    if let movementComponent = entity?.component(ofType: MovementComponent.self) {
      switch command! {
      case "left":
        movementComponent.moveTo(.left)
      case "right":
        movementComponent.moveTo(.right)
      case "stop right":
        movementComponent.stopMoving()
      case "stop left":
        movementComponent.stopMoving()
      case "jump":
        movementComponent.jump()
      case "stop jump":
        movementComponent.stopJump()
      case "hit":
        movementComponent.hit()
      case "stop hit":
        break
      default:
        print("command: \(String(describing: command))")
      }
    }
  }
}
