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
    
    spriteComponent.node.removeAllActions()
    spriteComponent.node.run(animationComponent.damage!, withKey: "damage")
  }
  
  
  // MARK: - GKState Life Cycle
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    // `spriteComponent` является вычисляемым свойством. Объявляем локальную версию, чтобы мы не вычисляли его несколько раз.
    let spriteComponent = self.spriteComponent
    
    if spriteComponent.node.action(forKey: "damage") == nil {
      stateMachine?.enter(IdleState.self)
    }
  }
  
  override func willExit(to nextState: GKState) {
    spriteComponent.node.removeAction(forKey: "damage")
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is IdleState.Type, is WalkingState.Type, is JumpingState.Type, is FallingState.Type, is HitState.Type:
      return true
    case is DamageState.Type:
      return false
    default:
      return false
    }
  }
}
