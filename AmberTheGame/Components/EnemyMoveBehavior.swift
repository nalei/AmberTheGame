import SpriteKit
import GameplayKit

class EnemyMoveBehavior: GKBehavior {
  init(targetSpeed: Float, seek: GKAgent, avoid: [GKAgent], obstacles: [GKObstacle]) {
    super.init()
    if targetSpeed > 0 {
      // Достичь целевой скорости
      setWeight(0.1, for: GKGoal(toReachTargetSpeed: targetSpeed))
      
      // Приблизиться к агенту (двигаться к ближайшему врагу)
      setWeight(0.1, for: GKGoal(toSeekAgent: seek))
      
      // Избежать сближения с группой других агентов (избежать скученности союзников)
      setWeight(0.9, for: GKGoal(toAvoid: avoid, maxPredictionTime: 1.0))
      
      // Избежать столкновения с указанными статическими препятствиями.
      setWeight(1.0, for: GKGoal(toAvoid: obstacles, maxPredictionTime: 1.0))
      
    }
  }
}
