import SpriteKit
import GameplayKit

class DamageState: GKState {
  // MARK: - Properties
  unowned var animationComponent: AnimationComponent
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) else {
      fatalError("A HitState's entity must have an SpriteComponent.")
    }
    return spriteComponent
  }
  
  // MARK: - Initializers
  
  required init(animationComponent: AnimationComponent) {
    self.animationComponent = animationComponent
  }
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    spriteComponent.node.run(animationComponent.damage!, withKey: "damage")
  }
  
  
  // MARK: - GKState Life Cycle
  
  override func willExit(to nextState: GKState) {
    super.willExit(to: nextState)
    
    spriteComponent.node.removeAction(forKey: "damage")
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is IdleState.Type, is WalkingState.Type, is JumpingState.Type, is FallingState.Type, is HitState.Type:
      return spriteComponent.node.action(forKey: "damage") == nil
    case is DamageState.Type:
      return false
    default:
      return false
    }
  }
}
