import SpriteKit
import GameplayKit

class HitState: GKState {
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
  
  
  // MARK: - GKState Life Cycle
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    spriteComponent.node.run(animationComponent.hit!, withKey: "hit")
    
    if let _ = previousState as? FallingState {
      spriteComponent.squashAndSretch(xScale: 1.3, yScale: 0.7)
    }
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    if spriteComponent.node.action(forKey: "hit") == nil {
      stateMachine?.enter(IdleState.self)
    }
  }
  
  override func willExit(to nextState: GKState) {
    super.willExit(to: nextState)
    
    spriteComponent.node.removeAction(forKey: "hit")
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is IdleState.Type, is WalkingState.Type, is JumpingState.Type, is FallingState.Type, is DamageState.Type:
      return true
    case is HitState.Type:
      return false
    default:
      return false
    }
  }
}
