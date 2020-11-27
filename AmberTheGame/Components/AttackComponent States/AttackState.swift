import SpriteKit
import GameplayKit

class AttackState: GKState {
  // MARK: - Properties
  
  unowned var entity: GKEntity
  
  /// Время, в течение которого объект находился в состоянии `AttackHitState`.
  var elapsedTime: TimeInterval = 0.0
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = entity.component(ofType: SpriteComponent.self) else {
      fatalError("A AttackHitState's entity must have an SpriteComponent.")
    }
    return spriteComponent
  }
  
  /// Вычисляемое свойство указывающее на `AttackComponent`.
  var attackComponent: AttackComponent {
    guard let attackComponent = entity.component(ofType: AttackComponent.self) else {
      fatalError("A AttackHitState's entity must have an AttackComponent.")
    }
    return attackComponent
  }
  
  
  // MARK: - Initializers
  
  required init(entity: GKEntity) {
    self.entity = entity
  }
  
  
  // MARK: - GKState Life Cycle
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
     
    // Сбросываем счетчик времени при входе в это состояние.
    elapsedTime = 0.0
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    // Обновляем счетчик времени в состоянии `AttackHitState`.
    elapsedTime += seconds
    
    // `attackComponent` и `spriteComponent` являются вычисляемыми свойствами. Объявляем локальные версии, чтобы мы не вычисляли их несколько раз.
    let attackComponent = self.attackComponent
    let spriteComponent = self.spriteComponent
    
    var startDamageTime = 0.1
    var endDamageTime = 0.2
    
    if entity is Skeleton {
      startDamageTime = 0.4
      endDamageTime = 0.6
    }
    
    // Добавляем `hitBox` в промежутке между `startDamageTime` и `endDamageTime` нахождения в состояни `AttackHitState`.
    if elapsedTime >= startDamageTime && elapsedTime <= endDamageTime {
      if attackComponent.hitBox.parent == nil {
        spriteComponent.node.addChild(attackComponent.hitBox)
      }
    } else {
      if attackComponent.hitBox.parent != nil {
        attackComponent.hitBox.removeFromParent()
      }
    }
    
    if spriteComponent.node.action(forKey: "hit") == nil {
      stateMachine?.enter(ReadyState.self)
    }
  }
  
  override func willExit(to nextState: GKState) {
    super.willExit(to: nextState)
    
    if attackComponent.hitBox.parent != nil {
      attackComponent.hitBox.removeFromParent()
    }
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is DamagedState.Type, is ReadyState.Type:
      return true
    default:
      return false
    }
  }
}

