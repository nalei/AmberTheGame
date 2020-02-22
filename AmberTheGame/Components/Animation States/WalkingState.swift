import SpriteKit
import GameplayKit

class WalkingState: GKState {
  unowned var animationComponent: AnimationComponent
  
  required init(animationComponent: AnimationComponent) {
    self.animationComponent = animationComponent
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is IdleState.Type:
      return true
    case is WalkingState.Type:
      return false
    case is JumpingState.Type:
      return true
    default:
      return false
    }
  }
  
  override func didEnter(from previousState: GKState?) {    
    if let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) {
      spriteComponent.node.run(SKAction(named: "amber-run")!, withKey: "amber-run")
      
      if let _ = previousState as? JumpingState {
        spriteComponent.squashAndSretch(xScale: 1.3, yScale: 0.7)
      }
    }
  }
  
}
