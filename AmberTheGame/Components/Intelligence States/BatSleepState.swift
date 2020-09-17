import SpriteKit
import GameplayKit

class BatSleepState: GKState {
  // MARK: - Properties
  
  unowned var entity: Bat
  
  
  // MARK: - Initializers
  
  required init(entity: Bat) {
    self.entity = entity
  }
  
  
  // MARK: - GKState Life Cycle
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    if let animationComponent = entity.component(ofType: AnimationComponent.self) {
      animationComponent.stateMachine?.enter(IdleState.self)
    }
    
    entity.agent.stopAgent()
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is AgentControlledState.Type:
      return true
    default:
      return false
    }
  }
  
  override func willExit(to nextState: GKState) {
    super.willExit(to: nextState)
    entity.agent.startAgent()
  }
}
