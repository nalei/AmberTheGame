import SpriteKit
import GameplayKit

class ReadyState: GKState {
  // MARK: - Properties
  
  unowned var entity: GKEntity
  
  
  // MARK: - Initializers
  
  required init(entity: GKEntity) {
    self.entity = entity
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is AttackState.Type, is DamagedState.Type:
      return true
    default:
      return false
    }
  }
}
