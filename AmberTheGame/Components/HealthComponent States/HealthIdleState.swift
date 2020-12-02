import SpriteKit
import GameplayKit

class HealthIdleState: GKState {
  // MARK: - Properties
  
  unowned var healthComponent: HealthComponent
  
  
  // MARK: - Initializers
  
  required init(healthComponent: HealthComponent) {
    self.healthComponent = healthComponent
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is HealthDamageState.Type:
      return true
    default:
      return false
    }
  }
}
