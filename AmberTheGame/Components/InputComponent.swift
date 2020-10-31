import SpriteKit
import GameplayKit

class InputComponent: GKComponent, ControlInputSourceDelegate {
  // MARK: - Properties
  
  var touchControlInputNode: TouchControlInputNode?
  
  var handledMoveButtonState: MovementComponent.FacingType?
  
  /**
   `InputComponent` имеет возможность игнорировать ввод, когда он отключен.
   */
  var isEnabled = true {
    didSet {
      if isEnabled {
        if let direction = handledMoveButtonState {
          movementComponent.moveTo(direction)
        }
      } else {
        if movementComponent.moveButtonPressed {
          handledMoveButtonState = movementComponent.facing
        } else {
          handledMoveButtonState = nil
        }
        
        movementComponent.stopMoving()
      }
    }
  }
  
  /// Вычисляемое свойство указывающее на `MovementComponent`.
  var movementComponent: MovementComponent {
    guard let movementComponent = entity?.component(ofType: MovementComponent.self) else {
      fatalError("A AttackComponent's entity must have a MovementComponent")
    }
    return movementComponent
  }
  
  
  // MARK: - Initializers
  
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
  
  
  // MARK: - GameInputDelegate
  
  func follow(command: String?) {
    if isEnabled {
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
        guard let attackComponent = entity?.component(ofType: AttackComponent.self) else { break }
        attackComponent.hit()
      case "stop hit":
        break
      default:
        print("command: \(String(describing: command)) not processed")
      }
    } else {
      switch command! {
      case "left":
        handledMoveButtonState = .left
      case "right":
        handledMoveButtonState = .right
      case "stop right":
        handledMoveButtonState = nil
      case "stop left":
        handledMoveButtonState = nil
      default:
        print("command: \(String(describing: command)) not processed")
      }
    }
  }
}
