import SpriteKit
import GameplayKit

class EnemyBehavior: GKBehavior {
  
  /// Создает поведение для движения к цели через вычисленный путь.
  static func behaviorAndPathPoints(forAgent agent: GKAgent2D, huntingAgent target: GKAgent2D, pathRadius: Float, inScene scene: LevelScene) -> (behavior: GKBehavior, pathPoints: [CGPoint]) {
    let behavior = EnemyBehavior()
    
    // Добавляем основные цели: достичь максимальной скорости и избегать препятствий.
    behavior.addTargetSpeedGoal(speed: agent.maxSpeed)
    behavior.addAvoidObstaclesGoal(forScene: scene)
    
    // Добавляем цель: избегать приближения к другим агентам.
    behavior.addAvoidAgentsGoal(forAgents: scene.entityManager.getAllAgentComponents())
    
    // Добавляем цель: следовать расчетному пути.
    let pathPoints = behavior.addGoalsToFollowPath(from: agent.position, to: target.position, pathRadius: pathRadius, inScene: scene)
    
    // Возвращаем кортеж, содержащий новое поведение и найденные точки пути для отладочной отрисовки.
    return (behavior, pathPoints)
  }
  
  /// Создает поведение, чтобы патрулировать путь, избегая препятствий на пути.
  static func behaviorPatrol(forAgent agent: GKAgent2D, patrollingPathWithPoints patrolPathPoints: [CGPoint], pathRadius: Float, inScene scene: LevelScene) -> GKBehavior {
    let behavior = EnemyBehavior()
    
    // Добавляем основные цели: достичь максимальной скорости и избегать препятствий.
    behavior.addTargetSpeedGoal(speed: agent.maxSpeed)
    behavior.addAvoidObstaclesGoal(forScene: scene)
    
    // Преобразуем путь патрулирования в массив `[vector_float2]`.
    let pathVectorPoints = patrolPathPoints.map { vector_float2($0) }
    
    // Создайте циклический (закрытый) `GKPath` из предоставленных точек пути с запрошенным радиусом пути.
    let path = GKPath(points: pathVectorPoints, radius: pathRadius, cyclical: true)
    
    // Добавляем цели "следовать по пути" и "остаться на пути".
    behavior.addFollowAndStayOnPathGoals(for: path)
    
    return behavior
  }
  
  /// Создает поведение, для движения к цели по прямой.
  static func behaviorFollow(forAgent agent: GKAgent2D, huntingAgent target: GKAgent2D, inScene scene: LevelScene) -> GKBehavior {
    let behavior = EnemyBehavior()
    
    // Добавляем основные цели: достичь максимальной скорости и избегать препятствий.
    behavior.addTargetSpeedGoal(speed: agent.maxSpeed)
    behavior.addAvoidObstaclesGoal(forScene: scene)
    
    // Добавляем цель: избегать приближения к другим агентам.
    behavior.addAvoidAgentsGoal(forAgents: scene.entityManager.getAllAgentComponents())
    
    // Добавляем цель: двигаться к агенту
    behavior.addSeekAgentGoal(forAgent: target)
    
    return behavior
  }
  
  /**
   Создает путь, обходящий препятствия между двумя точками, и добавляет цель, следовать по заданному пути.
   Возвращает массив `[CGPoint]` для отладочной отрисовки.
   */
  private func addGoalsToFollowPath(from startPoint: vector_float2, to endPoint: vector_float2, pathRadius: Float, inScene scene: LevelScene) -> [CGPoint] {
    // Конвертируем точки: `CGPoint` в узлы графа: `GPGraph`.
    guard let startNode = connectedNode(forPoint: startPoint, onObstacleGraphInScene: scene),
      let endNode = connectedNode(forPoint: endPoint, onObstacleGraphInScene: scene) else { return [] }
    
    // Удаляем узлы графа при выходе из функции!
    defer { scene.graph.remove([startNode, endNode]) }
    
    // Находим узлы пути между двумя узлами.
    let pathNodes = scene.graph.findPath(from: startNode, to: endNode) as! [GKGraphNode2D]
    
    // Валидный путь: `GKPath` не может быть создан если в нем менее 2 узлов.
    guard pathNodes.count > 1 else { return [] }
    
    // Создаем путь: `GKPath` из найденных узлов с запрошенным радиусом пути.
    let path = GKPath(graphNodes: pathNodes, radius: pathRadius)
    
    // Добавляем цели "следовать по пути" и "остаться на пути".
    addFollowAndStayOnPathGoals(for: path)
    
    // Конвертируем узлы пути `GKGraphNode2D` в точки: `CGPoint` для отладочной отрисовки.
    let pathPoints = pathNodes.map{ CGPoint($0.position) }
    return pathPoints
  }
  
  /**
   Создает узел графа поиска пути для заданной точки, игнорируя буфферную зону препятствий.
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
     Мы не можем найти путь к точке находящейся внутри буфферной зоны препятствий,
     */
    if pointNode.connectedNodes.isEmpty {
      // Предыдущая попытка подключения не удалась, поэтому удаляем не валидный узел из графа.
      scene.graph.remove([pointNode])
      
      // Ищем все препятствия мешающие построению.
      let intersectingObstacles = extrudedObstaclesContaining(point: point, inScene: scene)

      /*
       Подключаем узел к графу, игнорируя радиус буфера любого
       препятствия, мешающего построению.
       */
      scene.graph.connectUsingObstacles(node: pointNode, ignoringBufferRadiusOf: intersectingObstacles)

      // Если по-прежнему невозможно установить соединение, возвращаем `nil`.
      if pointNode.connectedNodes.isEmpty {
        scene.graph.remove([pointNode])
        return nil
      }
    }
    
    return pointNode
  }
  
  /**
   Рассчитывает все выдавленные препятствия, рядом с которыми находится заданная точка.
   Выдавливание основано на радиусе буфера графа.
   */
  private func extrudedObstaclesContaining(point: SIMD2<Float>, inScene scene: LevelScene) -> [GKPolygonObstacle] {
    /*
     Добавляем небольшой коэффициент (+5) к радиусу выдавливания,
     чтобы убедиться, мы включили все препятствия.
     */
    let extrusionRadius = GameplayConfiguration.Enemy.pathfindingGraphBufferRadius + 5
    
    /*
     Возвращает массив `polygonObstacles`, которые содержат указанную точку.
     
     Note: работает только для `polygonObstacles` на основе многоугольника.
     */
    return scene.polygonObstacles.filter { obstacle in
      // Retrieve all vertices for the polygon obstacle.
      let range = 0..<obstacle.vertexCount
      
      let polygonVertices = range.map { obstacle.vertex(at: $0) }
      guard !polygonVertices.isEmpty else { return false }
      
      let maxX = polygonVertices.max { $0.x < $1.x }!.x + extrusionRadius
      let maxY = polygonVertices.max { $0.y < $1.y }!.y + extrusionRadius
      
      let minX = polygonVertices.min { $0.x < $1.x }!.x - extrusionRadius
      let minY = polygonVertices.min { $0.y < $1.y }!.y - extrusionRadius
      
      return (point.x > minX && point.x < maxX) && (point.y > minY && point.y < maxY)
    }
  }
  
  
  // MARK: - Goals
  
  /// Достичь целевой скорости
  private func addTargetSpeedGoal(speed: Float) {
    setWeight(0.1, for: GKGoal(toReachTargetSpeed: speed))
  }
  
  /// Избежать сближения с группой других агентов (избежать скученности союзников)
  private func addAvoidAgentsGoal(forAgents agents: [GKAgent]) {
    setWeight(2.0, for: GKGoal(toAvoid: agents, maxPredictionTime: 1.0))
  }
  
  /// Избегать всех непроходимых препятствий на сцене.
  private func addAvoidObstaclesGoal(forScene scene: LevelScene) {
    setWeight(0.1, for: GKGoal(toAvoid: scene.polygonObstacles, maxPredictionTime: 1.0))
  }
  
  /// Приследовать цель
  private func addSeekAgentGoal(forAgent target: GKAgent) {
    setWeight(0.1, for: GKGoal(toSeekAgent: target))
  }
  
  /// Следовать и оставаться на пути
  private func addFollowAndStayOnPathGoals(for path: GKPath) {
    // Цель «следовать по пути» пытается удержать агента лицом вперед.
    setWeight(1.0, for: GKGoal(toFollow: path, maxPredictionTime: 1.0, forward: true))
    
    // Цель "остаться на пути" пытается удержать агента на пути в пределах радиуса пути.
    setWeight(1.0, for: GKGoal(toStayOn: path, maxPredictionTime: 1.0))
  }
}
