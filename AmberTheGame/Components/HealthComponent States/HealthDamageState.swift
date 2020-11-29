import SpriteKit
import GameplayKit

class HealthDamageState: GKState {
  // MARK: - Properties
  
  unowned var entity: GKEntity
  
  /// Время, в течение которого объект находился в состоянии `DamagedState`.
  var elapsedTime: TimeInterval = 0.0
  
  
  // MARK: - Initializers
  
  required init(entity: GKEntity) {
    self.entity = entity
  }
  
  
  // MARK: - GKState Life Cycle
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    // Сбросываем счетчик времени при входе в это состояние.
    elapsedTime = 0.0
    
    // Прерываем управление персонажем, пока он находится в `DamageState`.
    if let inputComponent = entity.component(ofType: InputComponent.self) {
      inputComponent.isEnabled = false;
    }
    
    // Наносим дамаг
    if let healthComponent = entity.component(ofType: HealthComponent.self) {
      healthComponent.applyDamageToSelf()
    }
    
    // Анимация: меняет цвет спрайта на белый, в течение 0.15c.
    if let spriteComponent = entity.component(ofType: SpriteComponent.self) {
      spriteComponent.node.run(SKAction.pulsedWhite(node: spriteComponent.node))
    }
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    // Обновляем счетчик времени в состоянии `DamagedState`.
    elapsedTime += seconds
    
    if elapsedTime >= GameplayConfiguration.Amber.damageStateDuration {
      stateMachine?.enter(HealthIdleState.self)
    }
  }
  
  override func willExit(to nextState: GKState) {
    super.willExit(to: nextState)
    
    if let inputComponent = entity.component(ofType: InputComponent.self) {
      inputComponent.isEnabled = true;
    }
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is HealthIdleState.Type:
      return true
    default:
      return false
    }
  }
}
