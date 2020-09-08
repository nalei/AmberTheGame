import SpriteKit
import GameplayKit

class AgentControlledState: GKState {
  // MARK: - Properties
  
  unowned var intelligenceComponent: IntelligenceComponent
  
  /// Таймер времени, прошедшего с момента последнего обновления поведения.
  var timeSinceBehaviorUpdate: TimeInterval = 0.0
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = intelligenceComponent.entity?.component(ofType: SpriteComponent.self) else {
      fatalError("A HitState's entity must have an SpriteComponent.")
    }
    return spriteComponent
  }
  
  
  // MARK: - Initializers
  
  required init(intelligenceComponent: IntelligenceComponent) {
    self.intelligenceComponent = intelligenceComponent
  }
  
  
  // MARK: - GKState Life Cycle
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    // Сбрасываем таймер времени, прошедшего с момента последнего обновления поведения.
    timeSinceBehaviorUpdate = 0.0
    
    // Назначаем поведение согласно мандату
    if let entity = intelligenceComponent.entity as? Enemy {
      entity.agent.behavior = entity.behaviorForCurrentMandate
    }
  }
  
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    // Обновляем таймер времени, прошедшего с момента последнего обновления поведения.
    timeSinceBehaviorUpdate += seconds
    
    // Проверяем, прошло ли достаточно времени с момента последнего обновления поведения, и обновляем поведение, если это так.
    if timeSinceBehaviorUpdate >= 0.25 {
      
      // Когда `Bat` возвращается к `nestPoint` и приближается достаточно близко, он должен прекратить движение.
      if let bat = intelligenceComponent.entity as? Bat {
        
        if case let .returnToPosition(position) = bat.mandate, bat.distanceToPoint(otherPoint: position) <= 10 {
          if let animationComponent = bat.component(ofType: AnimationComponent.self) {
            animationComponent.stateMachine?.enter(IdleState.self)
          }
          spriteComponent.node.position = CGPoint(position)
          bat.mandate = .stop
        }
      }
      
      // Назначаем поведение согласно мандату
      if let entity = intelligenceComponent.entity as? Enemy {
        entity.agent.behavior = entity.behaviorForCurrentMandate
      }
      
      // Сбрасываем таймер времени, прошедшего с момента последнего обновления поведения.
      timeSinceBehaviorUpdate = 0.0
    }
  }
  
  override func willExit(to nextState: GKState) {
    super.willExit(to: nextState)
    
    // Отменяем активность агента.
    if let entity = intelligenceComponent.entity as? Enemy {
      entity.agent.behavior = GKBehavior()
    }
  }
}
