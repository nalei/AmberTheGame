import SpriteKit
import GameplayKit

class HitState: GKState {
  // MARK: - Properties
  
  unowned var entity: GKEntity
  
  var hitAnimation: SKAction
  
  /// Время, в течение которого объект находился в состоянии `AttackHitState`.
  var elapsedTime: TimeInterval = 0.0
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = entity.component(ofType: SpriteComponent.self) else {
      fatalError("A HitState's entity must have an SpriteComponent.")
    }
    return spriteComponent
  }
  
  /// Вычисляемое свойство указывающее на `HealthComponent`.
  var healthComponent: HealthComponent {
    guard let healthComponent = entity.component(ofType: HealthComponent.self) else {
      fatalError("A HitState's entity must have an HealthComponent.")
    }
    return healthComponent
  }
  
  
  // MARK: - Initializers
  
  required init(entity: GKEntity, hitAnimation: SKAction?) {
    self.entity = entity
    self.hitAnimation = hitAnimation! // !!!
  }
  
  
  // MARK: - GKState Life Cycle
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    // Сбросываем счетчик времени при входе в это состояние.
    elapsedTime = 0.0
    
    spriteComponent.node.run(hitAnimation, withKey: "hit")
    
    if let _ = previousState as? FallingState {
      spriteComponent.squashAndSretch(xScale: 1.3, yScale: 0.7)
    }
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    // Обновляем счетчик времени в состоянии `AttackHitState`.
    elapsedTime += seconds
    
    // `attackComponent` и `spriteComponent` являются вычисляемыми свойствами. Объявляем локальные версии, чтобы мы не вычисляли их несколько раз.
    let healthComponent = self.healthComponent
    let spriteComponent = self.spriteComponent
    
    var startDamageTime = 0.1
    var endDamageTime = 0.2
    
    if entity is Skeleton {
      startDamageTime = 0.4
      endDamageTime = 0.6
    }
    
    // Добавляем `hitBox` в промежутке между `startDamageTime` и `endDamageTime` нахождения в состояни `HitState`.
    if elapsedTime >= startDamageTime && elapsedTime <= endDamageTime {
      if healthComponent.hitBox.parent == nil {
        spriteComponent.node.addChild(healthComponent.hitBox)
      }
    } else {
      if healthComponent.hitBox.parent != nil {
        healthComponent.hitBox.removeFromParent()
      }
    }
    
    if spriteComponent.node.action(forKey: "hit") == nil {
      stateMachine?.enter(IdleState.self)
    }
  }
  
  override func willExit(to nextState: GKState) {
    super.willExit(to: nextState)
    
    if healthComponent.hitBox.parent != nil {
      healthComponent.hitBox.removeFromParent()
    }
    
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
