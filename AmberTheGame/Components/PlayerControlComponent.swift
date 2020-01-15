import GameplayKit
import SpriteKit

class PlayerControlComponent: GKComponent,  ControlInputSourceDelegate{
  var touchControlNode : TouchControlInputNode?
  var character : CharacterNode?
  
  func setupControls(camera : SKCameraNode, scene: SKScene) {
    touchControlNode = TouchControlInputNode(frame: scene.frame)
    touchControlNode?.inputDelegate = self
    touchControlNode?.position = CGPoint.zero
    
    camera.addChild(touchControlNode!)
    
    if (character == nil) {
      if let nodeComponent = self.entity?.component(ofType: GKSKNodeComponent.self) {
        character = nodeComponent.node as? CharacterNode
      }
    }
  }
  
  func follow(command: String?) {
    if (character != nil) {
      switch command! {
      case "left":
        character?.left = true
      case "cancel left", "stop left":
        character?.left = false
      case "right":
        character?.right = true
      case "cancel right", "stop right":
        character?.right = false
      case "A":
        character?.jump = true
      case "cancel A", "stop A":
        character?.jump = false
      default:
        print("command: \(String(describing: command))")
      }
    }
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    character?.stateMachine?.update(deltaTime: seconds)
  }
}
