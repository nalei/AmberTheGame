import SpriteKit
import GameplayKit

class OnGroundState: GKState {
  unowned var movementComponent: MovementComponent
  
  let walkSpeed: CGFloat = 320
  let maxJump: CGFloat  = 150
  
  var accel: CGFloat  = 40
  var decel: CGFloat  = 30
  var hSpeed: CGFloat = 0
  
  /// The `SpriteComponent` for this component's entity.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = movementComponent.entity?.component(ofType: SpriteComponent.self) else {
      fatalError("A MovementComponent's entity must have a SpriteComponent")
    }
    return spriteComponent
  }
  
  
  
  required init(movementComponent: MovementComponent) {
    self.movementComponent = movementComponent
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is OnGroundState.Type:
      return false
    case is OnAirState.Type:
      return true
    default:
      return false
    }
  }
  
  override func didEnter(from previousState: GKState?) {
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
  }
}

