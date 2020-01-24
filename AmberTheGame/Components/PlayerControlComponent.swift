import GameplayKit
import SpriteKit

class PlayerControlComponent: GKComponent,  ControlInputSourceDelegate {
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
    if let moveComponent = entity?.component(ofType: MoveComponent.self){
      switch command! {
      case "left":
        moveComponent.moveLeft()
      case "stop left":
        moveComponent.stopMoving()
      case "right":
        moveComponent.moveRight()
      case "stop right":
        moveComponent.stopMoving()
      case "jump":
          moveComponent.jump()
      case "stop jump":
          ()
      default:
        print("command: \(String(describing: command))")
      }
    }
  }
  
//  func approach(start: CGFloat, end: CGFloat, shift: CGFloat) -> CGFloat {
//    return start < end
//      ? min(start + shift, end)
//      : max(start - shift, end)
//  }
}
