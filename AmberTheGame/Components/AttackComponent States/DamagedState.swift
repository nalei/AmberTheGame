import SpriteKit
import GameplayKit

class DamagedState: GKState {
  // MARK: - Properties
  
  unowned var entity: GKEntity
  
  
  // MARK: - Initializers
  
  required init(entity: GKEntity) {
    self.entity = entity
  }
  
  
  // MARK: - GKState Life Cycle
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    // Наносим дамаг
    if let attackComponent = entity.component(ofType: AttackComponent.self) {
      attackComponent.applyDamageToSelf()
    }
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is ReadyState.Type, is AttackState.Type:
      return true
    default:
      return false
    }
  }
}
