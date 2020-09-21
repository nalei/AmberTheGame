import SpriteKit
import GameplayKit

class SkeletonMoveState: GKState {
  // MARK: - Properties
  
  unowned var entity: Skeleton
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = entity.component(ofType: SpriteComponent.self) else {
      fatalError("A SkeletonMoveState's entity must have an SpriteComponent.")
    }
    return spriteComponent
  }
  
  var targetPosition: vector_float2 {
    guard let targetPosition = entity.targetPosition else { fatalError("A SkeletonMoveState's entity must have a targetPosition set.") }
    return targetPosition
  }
  
  
  // MARK: - Initializers
  
  required init(entity: Skeleton) {
    self.entity = entity
  }
  
  
  // MARK: - GKState Life Cycle
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    // 'targetPosition' является вычисляемым свойством. Объявляем локальную переменную, чтобы не вычислять его несколько раз.
    let targetPosition = self.targetPosition
    
    let dx = targetPosition.x - entity.agent.position.x
    
    if let movementComponent = entity.component(ofType: MovementComponent.self) {
      movementComponent.moveTo((dx < 0) ? .left : .right)
    }
  }
  
  override func willExit(to nextState: GKState) {
    super.willExit(to: nextState)
    
    if let movementComponent = entity.component(ofType: MovementComponent.self) {
      movementComponent.stopMoving()
    }
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is AgentControlledState.Type, is SkeletonAttackState.Type:
      return true
    default:
      return false
    }
  }
}
