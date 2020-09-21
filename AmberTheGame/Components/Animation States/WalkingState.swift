import SpriteKit
import GameplayKit

class WalkingState: GKState {
  // MARK: - Properties
  
  unowned var animationComponent: AnimationComponent
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) else {
      fatalError("A WalkingState's entity must have an SpriteComponent.")
    }
    return spriteComponent
  }
  
  
  // MARK: - Initializers
  
  required init(animationComponent: AnimationComponent) {
    self.animationComponent = animationComponent
  }
  
  
  // MARK: - GKState Life Cycle
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    spriteComponent.node.run(animationComponent.run!, withKey: "run")
    
    if let _ = previousState as? FallingState {
      spriteComponent.squashAndSretch(xScale: 1.3, yScale: 0.7)
    }
  }
  
  override func willExit(to nextState: GKState) {
    super.willExit(to: nextState)
    
    spriteComponent.node.removeAction(forKey: "run")
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is IdleState.Type, is JumpingState.Type, is FallingState.Type, is HitState.Type, is DamageState.Type:
      return true
    case is WalkingState.Type:
      return false
    default:
      return false
    }
  }
}
