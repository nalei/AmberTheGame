import SpriteKit
import GameplayKit

class AgentControlledState: GKState {
  // MARK: - Properties
  
  unowned var entity: Enemy
  
  /// Таймер времени, прошедшего с момента последнего обновления поведения.
  var timeSinceBehaviorUpdate: TimeInterval = 0.0
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = entity.component(ofType: SpriteComponent.self) else {
      fatalError("A AgentControlledState's entity must have an SpriteComponent.")
    }
    return spriteComponent
  }
  
  
  // MARK: - Initializers
  
  required init(entity: Enemy) {
    self.entity = entity
  }
  
  
  // MARK: - GKState Life Cycle
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    // Сбрасываем таймер времени, прошедшего с момента последнего обновления поведения.
    timeSinceBehaviorUpdate = 0.0
    
    // Назначаем поведение согласно мандату
    entity.agent.behavior = entity.behaviorForCurrentMandate
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    // Обновляем таймер времени, прошедшего с момента последнего обновления поведения.
    timeSinceBehaviorUpdate += seconds
    
    // Проверяем, прошло ли достаточно времени с момента последнего обновления поведения, и обновляем поведение, если это так.
    if timeSinceBehaviorUpdate >= 0.25 {
      
      // Когда `Bat` возвращается к `nestPoint` и приближается достаточно близко, он должен прекратить движение.
      if let bat = entity as? Bat {
        if case let .returnToPosition(position) = bat.mandate, bat.distanceToPoint(otherPoint: position) <= 10 {
          
          spriteComponent.node.position = CGPoint(position)
          
          entity.mandate = .passiveAgent
          
          stateMachine?.enter(BatSleepState.self)
        }
      }
      
      // Назначаем поведение согласно мандату
      entity.agent.behavior = entity.behaviorForCurrentMandate
      
      // Сбрасываем таймер времени, прошедшего с момента последнего обновления поведения.
      timeSinceBehaviorUpdate = 0.0
    }
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is BatSleepState.Type, is SkeletonMoveState.Type:
      return true
    default:
      return false
    }
  }
  
  override func willExit(to nextState: GKState) {
    super.willExit(to: nextState)
    
    // Отменяем активность агента.
    entity.agent.behavior = GKBehavior()
  }
}
