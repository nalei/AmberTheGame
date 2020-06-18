import SpriteKit
import GameplayKit

class HitState: GKState {
  unowned var animationComponent: AnimationComponent
  
  required init(animationComponent: AnimationComponent) {
    self.animationComponent = animationComponent
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is IdleState.Type:
      return true
    case is WalkingState.Type:
      return true
    case is JumpingState.Type:
      return true
    case is FallingState.Type:
      return true
    case is HitState.Type:
      return false
    default:
      return false
    }
  }
  
  override func didEnter(from previousState: GKState?) {
    guard let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) else { return }
    
    spriteComponent.node.run(animationComponent.hit!, withKey: "hit")
    spriteComponent.node.size = CGSize(width: 267, height: 267)
  }
}
