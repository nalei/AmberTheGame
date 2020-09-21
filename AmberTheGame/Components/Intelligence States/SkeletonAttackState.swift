import SpriteKit
import GameplayKit

class SkeletonAttackState: GKState {
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
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
  }
  
  override func willExit(to nextState: GKState) {
    super.willExit(to: nextState)
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
