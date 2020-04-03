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
    case is FallingState.Type:
      return true
    default:
      return false
    }
  }
  
  override func didEnter(from previousState: GKState?) {
    guard let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) else { return }
    
    spriteComponent.node.removeAllActions()
    spriteComponent.node.texture = SKTexture(imageNamed: "goblin-idle")
    
    if let _ = previousState as? FallingState {
      spriteComponent.squashAndSretch(xScale: 1.3, yScale: 0.7)
    }
  }
}
