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
    case is FallingState.Type:
      return true
    default:
      return false
    }
  }
  
  override func didEnter(from previousState: GKState?) {    
    guard let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) else { return }
    
    spriteComponent.node.run(SKAction(named: "goblin-run")!, withKey: "goblin-run")
    
    if let _ = previousState as? FallingState {
      spriteComponent.squashAndSretch(xScale: 1.3, yScale: 0.7)
    }
  }
}
