import SpriteKit
import GameplayKit

class IdleState: GKState {
  unowned var animationComponent: AnimationComponent
  
  required init(animationComponent: AnimationComponent) {
    self.animationComponent = animationComponent
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is IdleState.Type:
      return false
    case is WalkingState.Type:
      return true
    case is JumpingState.Type:
      return true
    default:
      return false
    }
  }
  
  override func didEnter(from previousState: GKState?) {
    if let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) {
      spriteComponent.node.removeAllActions()
      spriteComponent.node.texture = SKTexture(imageNamed: "amber-idle")
      
      if let _ = previousState as? JumpingState {
        spriteComponent.squashAndSretch(xScale: 1.3, yScale: 0.7)
      }
    }
  }
}
