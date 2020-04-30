import SpriteKit
import GameplayKit

class EnemyMoveBehavior: GKBehavior {
  init(targetSpeed: Float, seek: GKAgent) {
    super.init()
    if targetSpeed > 0 {
      // Достичь целевой скорости
      setWeight(0.1, for: GKGoal(toReachTargetSpeed: targetSpeed))
      
      // Приблизиться к агенту (двигаться к ближайшему врагу)
      setWeight(0.5, for: GKGoal(toSeekAgent: seek))
    }
  }
}
