import SpriteKit
import GameplayKit

class IdleState: GKState {
  unowned var animationComponent: AnimationComponent
  
  required init(animationComponent: AnimationComponent) {
    self.animationComponent = animationComponent
  }
  
  override func didEnter(from previousState: GKState?) {
    guard let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) else { return }
    
    spriteComponent.node.removeAllActions()
    spriteComponent.node.texture = animationComponent.idle
    
    if let _ = previousState as? FallingState {
      spriteComponent.squashAndSretch(xScale: 1.3, yScale: 0.8)
    }
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is WalkingState.Type, is JumpingState.Type, is FallingState.Type, is HitState.Type:
      return true
    case is IdleState.Type:
      return false
    default:
      return false
    }
  }
}
