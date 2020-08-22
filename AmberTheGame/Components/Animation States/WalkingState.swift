import SpriteKit
import GameplayKit

class WalkingState: GKState {
  // MARK: - Properties
  
  unowned var animationComponent: AnimationComponent
  
  /// Таймер времени, прошедшего с момента последнего обновления поведения.
  var timeSinceBehaviorUpdate: TimeInterval = 0.0
  
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
    
    // Сбрасываем таймер времени, прошедшего с момента последнего обновления поведения.
    timeSinceBehaviorUpdate = 0.0
    
    spriteComponent.node.run(animationComponent.run!, withKey: "run")
    
    if let _ = previousState as? FallingState {
      spriteComponent.squashAndSretch(xScale: 1.3, yScale: 0.7)
    }
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    // Обновляем таймер времени, прошедшего с момента последнего обновления поведения.
    timeSinceBehaviorUpdate += seconds
    
    // Проверяем, прошло ли достаточно времени с момента последнего обновления поведения, и обновляем поведение, если это так.
    if timeSinceBehaviorUpdate >= 0.25 {
      
      // Когда `Bat` возвращается к `nestPoint` и приближается достаточно близко, он должен прекратить движение.
      if let entity = animationComponent.entity as? Bat {
        
        if case let .returnToPosition(position) = entity.mandate, entity.distanceToPoint(otherPoint: position) <= 30 {
          stateMachine?.enter(IdleState.self)
          entity.mandate = .sleep
        }
      }
      
      // Сбрасываем таймер времени, прошедшего с момента последнего обновления поведения.
      timeSinceBehaviorUpdate = 0.0
    }
  }
  
  override func willExit(to nextState: GKState) {
    
    spriteComponent.node.removeAction(forKey: "run")
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is IdleState.Type, is JumpingState.Type, is FallingState.Type, is HitState.Type, is DamageState.Type:
      return true
    case is WalkingState.Type:
      return false
    default:
      return false
    }
  }
}
