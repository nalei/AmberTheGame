import SpriteKit
import GameplayKit

class SkeletonMoveState: GKState {
  // MARK: - Properties
  
  unowned var entity: Skeleton
  
  
  // MARK: - Initializers
  
  required init(entity: Skeleton) {
    self.entity = entity
  }
  
  
  // MARK: - GKState Life Cycle
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    if let animationComponent = entity.component(ofType: AnimationComponent.self) {
      animationComponent.stateMachine?.enter(WalkingState.self)
    }
    
    if let movementComponent = entity.component(ofType: MovementComponent.self) {
      movementComponent.moveTo(.left)
    }
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is AgentControlledState.Type:
      return true
    default:
      return false
    }
  }
}
