import SpriteKit
import GameplayKit

class EnemyBehavior: GKBehavior {
  
  /**
   Создает узел на графе поиска пути для заданной точки,
   игнорируя радиус буфера  препятствий.
   
   Возвращает `nil` если соединение не может быть установлено.
   */
  private func connectedNode(forPoint point: vector_float2, onObstacleGraphInScene scene: LevelScene) -> GKGraphNode2D? {
    // Создаем узел графа для этой точки.
    let pointNode = GKGraphNode2D(point: point)
    
    // Попробуем подключить этот узел к графу.
    scene.graph.connectUsingObstacles(node: pointNode)
    
    /*
     Проверяем, смогли ли мы подключить узел к графу.
     Если нет, это означает, что точка находится внутри буферной зоны препятствия.
     Мы не можем найти путь к точке вне графа, поэтому мы пытаемся найти ближайшую
     точку на графе и найти путь вместо этого.
     */
    if pointNode.connectedNodes.isEmpty {
      
      //TODO: Реализовать поиск ближайшей валидной точки
      
      scene.graph.remove([pointNode])
      return nil
    }
    
    return pointNode
  }
  
  /// Избегать всех непроходимых препятствий на сцене.
  private func addAvoidObstaclesGoal(forScene scene: LevelScene) {
    setWeight(1.0, for: GKGoal(toAvoid: scene.polygonObstacles, maxPredictionTime: 1.0))
  }
  
  /// Достичь целевой скорости
  private func addTargetSpeedGoal(speed: Float) {
    setWeight(0.5, for: GKGoal(toReachTargetSpeed: speed))
  }
  
  /// Следовать и оставаться на пути
  private func addFollowAndStayOnPathGoals(for path: GKPath) {
    // Цель «следовать по пути» пытается удержать агента лицом вперед.
    setWeight(1.0, for: GKGoal(toFollow: path, maxPredictionTime: 1.0, forward: true))
    
    // Цель "остаться на пути" пытается удержать агента на пути в пределах радиуса пути.
    setWeight(1.0, for: GKGoal(toStayOn: path, maxPredictionTime: 1.0))
  }
}
