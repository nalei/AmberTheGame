import GameplayKit
import SpriteKit

class  OnAirState: GKState {
  unowned var movementComponent: MovementComponent
  
  required init(movementComponent: MovementComponent) {
    self.movementComponent = movementComponent
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is OnGroundState.Type:
      return true
    case is OnAirState.Type:
      return false
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

