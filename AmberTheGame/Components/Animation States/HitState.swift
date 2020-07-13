import SpriteKit
import GameplayKit

class HitState: GKState {
  // MARK: - Properties
  unowned var animationComponent: AnimationComponent
  
  /// Время, в течение которого объект находился в состоянии `AttackState`.
  var elapsedTime: TimeInterval = 0.0
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) else {
      fatalError("A HitState's entity must have an SpriteComponent.")
    }
    return spriteComponent
  }
  
  /// Вычисляемое свойство указывающее на `AttackComponent`.
  var attackComponent: AttackComponent {
    guard let attackComponent = animationComponent.entity?.component(ofType: AttackComponent.self) else {
      fatalError("A HitState's entity must have an AttackComponent.")
    }
    return attackComponent
  }
  
  
  // MARK: - Initializers
  
  required init(animationComponent: AnimationComponent) {
    self.animationComponent = animationComponent
  }
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    // Сбросываем счетчик времени при входе в это состояние.
    elapsedTime = 0.0
    
    spriteComponent.node.removeAllActions()
    spriteComponent.node.run(animationComponent.hit!, withKey: "hit")
    
    if let _ = previousState as? FallingState {
      spriteComponent.squashAndSretch(xScale: 1.3, yScale: 0.7)
    }
  }
  
  
  // MARK: - GKState Life Cycle
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    // `spriteComponent` является вычисляемым свойством. Объявляем локальную версию, чтобы мы не вычисляли его несколько раз.
    let spriteComponent = self.spriteComponent
    
    // Обновляем счетчик времени в состоянии `AttackState`.
    elapsedTime += seconds
    
    if elapsedTime >= 0.1 && elapsedTime <= 0.3 {
      if attackComponent.hitBox.parent == nil {
        spriteComponent.node.addChild(attackComponent.hitBox)
      }
    } else {
      if attackComponent.hitBox.parent != nil {
        attackComponent.hitBox.removeFromParent()
      }
    }
    
    if spriteComponent.node.action(forKey: "hit") == nil {
      stateMachine?.enter(IdleState.self)
    }
  }
  
  override func willExit(to nextState: GKState) {
    spriteComponent.node.removeAction(forKey: "hit")
    
    if attackComponent.hitBox.parent != nil {
      attackComponent.hitBox.removeFromParent()
    }
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
