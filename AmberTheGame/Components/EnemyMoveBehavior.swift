import SpriteKit
import GameplayKit

class EnemyMoveBehavior: GKBehavior {
  init(targetSpeed: Float) {
    super.init()
    if targetSpeed > 0 {
      // Достичь целевой скорости
      setWeight(0.1, for: GKGoal(toReachTargetSpeed: targetSpeed))
    }
  }
}
