import SpriteKit
import GameplayKit

class SkeletonAttackState: GKState {
  // MARK: - Properties
  
  unowned var entity: Skeleton
  
  /// Время, в течение которого объект находился в состоянии `SkeletonAttackState`.
  var elapsedTime: TimeInterval = 0.0
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = entity.component(ofType: SpriteComponent.self) else {
      fatalError("A SkeletonMoveState's entity must have an SpriteComponent.")
    }
    return spriteComponent
  }
  
  
  // MARK: - Initializers
  
  required init(entity: Skeleton) {
    self.entity = entity
  }
  
  
  // MARK: - GKState Life Cycle
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    // Сбросываем счетчик времени при входе в это состояние.
    elapsedTime = 0.0
    
    if let healthComponent = entity.component(ofType: HealthComponent.self) {
      healthComponent.hit()
    }
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    // Обновляем счетчик времени в состоянии `SkeletonAttackState`.
    elapsedTime += seconds
    
    if elapsedTime >= 0.6 {
      stateMachine?.enter(AgentControlledState.self)
    }
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is AgentControlledState.Type, is SkeletonMoveState.Type:
      return true
    case is SkeletonAttackState.Type:
      return false
    default:
      return false
    }
  }
}
