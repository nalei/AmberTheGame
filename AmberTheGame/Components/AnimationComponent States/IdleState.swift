import SpriteKit
import GameplayKit

class IdleState: GKState {
  var animationComponent: AnimationComponent
  
  required init(animationComponent: AnimationComponent) {
    self.animationComponent = animationComponent
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is WalkingState.Type
  }
}
