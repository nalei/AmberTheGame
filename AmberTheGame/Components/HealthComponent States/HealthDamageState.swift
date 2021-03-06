import SpriteKit
import GameplayKit

class HealthDamageState: GKState {
  // MARK: - Properties
  
  unowned var healthComponent: HealthComponent
  
  /// Время, в течение которого объект находился в состоянии `HealthDamageState`.
  var elapsedTime: TimeInterval = 0.0
  
  
  // MARK: - Initializers
  
  required init(healthComponent: HealthComponent) {
    self.healthComponent = healthComponent
  }
  
  
  // MARK: - GKState Life Cycle
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    // Сбросываем счетчик времени при входе в это состояние.
    elapsedTime = 0.0
    
    // Наносим дамаг
    healthComponent.hp -= 1
    
    if healthComponent.hp == 0 {
      healthComponent.death()
    }
    
    // Прерываем управление персонажем, пока он находится в `HealthDamageState`.
    if let inputComponent = healthComponent.entity?.component(ofType: InputComponent.self) {
      inputComponent.isEnabled = false;
    }
    
    if let spriteComponent = healthComponent.entity?.component(ofType: SpriteComponent.self) {
      // Откидываем `Amber` назад, при дамаге
      if spriteComponent.entity is Amber {
        spriteComponent.bounceBack(force: 200)
      }
      
      spriteComponent.pulsedWhite()
    }
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    // Обновляем счетчик времени в состоянии `HealthDamageState`.
    elapsedTime += seconds
    
    if elapsedTime >= GameplayConfiguration.Amber.damageStateDuration {
      stateMachine?.enter(HealthIdleState.self)
    }
  }
  
  override func willExit(to nextState: GKState) {
    super.willExit(to: nextState)
    
    if let inputComponent = healthComponent.entity?.component(ofType: InputComponent.self) {
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
