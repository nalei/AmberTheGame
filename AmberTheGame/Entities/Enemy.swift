import SpriteKit
import GameplayKit

class Enemy: GKEntity, GKAgentDelegate {
  // MARK: - Nested types
  
  /// Мандат, то есть цель, которую `Enemy` ставит перед собой.
  enum EnemyMandate {
    // Бездействовать (агент привязан к физическому телу объекта).
    case passiveAgent
    
    // Охотиться на другого агента.
    case huntAgent(GKAgent2D)
    
    // Следовать по пути патрулирования.
    case followPatrolPath
    
    // Вернуться на заданную позицию.
    case returnToPosition(vector_float2)
  }
  
  
  // MARK: - Properties
  
  /// Цель, которую в настоящее время пытается достичь `Enemy`.
  var mandate: EnemyMandate = .passiveAgent
  
  /// Точки, которые `Enemy` должен патрулировать, когда не охотится.
  var patrolPoints: [CGPoint]?
  
  /// Вычисляемое свойство `GKBehavior` возвращает поведение для `Enemy`
  var behaviorForCurrentMandate: GKBehavior {
    guard let levelScene = component(ofType: SpriteComponent.self)?.node.scene as? LevelScene else {
      return GKBehavior()
    }
    
    let agentBehavior: GKBehavior
    let radius: Float
    
    // `debugPathPoints`, `debugPathShouldCycle`, `debugColor` используются только для отладочной отрисовки
    let debugPathPoints: [CGPoint]
    var debugPathShouldCycle = false
    let debugColor: SKColor
    
    switch mandate {
      case .passiveAgent:
        return GKBehavior()
        
      case .followPatrolPath:
        guard let pathPoints = patrolPoints else { return GKBehavior() }
        radius = GameplayConfiguration.Enemy.patrolPathRadius
        agentBehavior = EnemyBehavior.behaviorPatrol(forAgent: agent, patrollingPathWithPoints: pathPoints, pathRadius: radius, inScene: levelScene)
        debugPathPoints = pathPoints
        debugPathShouldCycle = true
        debugColor = SKColor.green
        
      case let .huntAgent(targetAgent):
        // agentBehavior = EnemyBehavior.behaviorFollow(forAgent: agent, huntingAgent: targetAgent, inScene: levelScene)
        radius = GameplayConfiguration.Enemy.huntPathRadius
        (agentBehavior, debugPathPoints) = EnemyBehavior.behaviorAndPathPoints(forAgent: agent, huntingAgent: targetAgent, pathRadius: radius, inScene: levelScene)
        debugColor = SKColor.red
        
      case let .returnToPosition(position):
        radius = GameplayConfiguration.Enemy.patrolPathRadius
        (agentBehavior, debugPathPoints) = EnemyBehavior.behaviorAndPathPoints(forAgent: agent, returningToPoint: position, pathRadius: radius, inScene: levelScene)
        debugColor = SKColor.yellow
    }
    
    if levelScene.debugDrawingEnabled {
      drawDebugPath(path: debugPathPoints, cycle: debugPathShouldCycle, color: debugColor, radius: radius)
    } else {
      debugNode.removeAllChildren()
    }
    
    return agentBehavior
  }
  
  /// Вычисляемое свойство указывающее на `AgentComponent`.
  var agent: AgentComponent {
    guard let agent = component(ofType: AgentComponent.self) else { fatalError("A Enemy entity must have a GKAgent2D component.") }
    return agent
  }
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = component(ofType: SpriteComponent.self) else { fatalError("A Enemy must have an SpriteComponent.") }
    return spriteComponent
  }
  
  /// Используется для смещения положения агента относительно центра спрайта
  var agentOffset = CGPoint.zero
  
  /// Используется для фигур, представляющих текущий путь для отладочной отрисовки.
  var debugNode = SKNode()
  
  
  // MARK: - Initialization
  
  
  // MARK: - GKAgentDelegate
  
  func agentWillUpdate(_: GKAgent) {
    /*
     `GKAgent`s не работают в физическом движке SpriteKit и не подвержены физическим столкновениям SpriteKit.
     По этому положение агента может иметь значения, которые недопустимы в физическом моделировании SpriteKit.
     Чтобы противостоять этому. Прежде чем агент обновит позицию, устанавливаем агента в позицию спрайта.
     */
    updateAgentPositionToMatchNodePosition()
  }
  
  func agentDidUpdate(_: GKAgent) {
    // `spriteComponent` является вычисляемым свойством. Объявляем локальную версию, чтобы мы не вычисляли его несколько раз.
    let spriteComponent = self.spriteComponent
    
    if agent.velocity.x < 0.0 {
      spriteComponent.node.xScale = -1
    }
    if agent.velocity.x > 0.0 {
      spriteComponent.node.xScale = 1
    }
    
    // После того, как агент обновит позицию, устанавливаем спрайт в позицию агента
    updateNodePositionToMatchAgentPosition()
  }
  
  
  // MARK: - Convenience
  
  func distanceToPoint(otherPoint: vector_float2) -> Float {
    let deltaX = agent.position.x - otherPoint.x
    let deltaY = agent.position.y - otherPoint.y
    
    return hypot(deltaX, deltaY)
  }
  
  ///  Устанавливает агента в позицию спрайта (плюс смещение).
  func updateAgentPositionToMatchNodePosition() {
    // `spriteComponent` является вычисляемым свойством. Объявляем локальную версию, чтобы мы не вычисляли его несколько раз.
    let spriteComponent = self.spriteComponent
    
    let spriteComponentPosition = CGPoint(
      x: spriteComponent.node.position.x + agentOffset.x,
      y: spriteComponent.node.position.y + agentOffset.y
    )
    
    agent.position = vector_float2(spriteComponentPosition)
  }
  
  /// Устанавливает спрайт в позицию агента  (плюс смещение).
  func updateNodePositionToMatchAgentPosition() {
    // `agent` является вычисляемым свойством. Объявляем локальную версию, чтобы мы не вычисляли его несколько раз.
    let agentPosition = CGPoint(agent.position)
    
    spriteComponent.node.position = CGPoint(x: agentPosition.x - agentOffset.x, y: agentPosition.y - agentOffset.y)
  }
  
  
  // MARK: - Debug Path Drawing
  
  func drawDebugPath(path: [CGPoint], cycle: Bool, color: SKColor, radius: Float) {
    guard path.count > 1 else { return }
    
    debugNode.removeAllChildren()
    
    var drawPath = path
    
    if cycle {
      drawPath += [drawPath.first!]
    }
    
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    // Use RGB component accessor common between `UIColor` and `NSColor`.
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    let strokeColor = SKColor(red: red, green: green, blue: blue, alpha: 0.4)
    let fillColor = SKColor(red: red, green: green, blue: blue, alpha: 0.2)
    
    for index in 0..<drawPath.count - 1 {
      let current = CGPoint(x: drawPath[index].x, y: drawPath[index].y)
      let next = CGPoint(x: drawPath[index + 1].x, y: drawPath[index + 1].y)
      
      let circleNode = SKShapeNode(circleOfRadius: CGFloat(agent.radius))
      circleNode.strokeColor = strokeColor
      circleNode.fillColor = fillColor
      circleNode.position = current
      debugNode.addChild(circleNode)
      
      let deltaX = next.x - current.x
      let deltaY = next.y - current.y
      let rectNode = SKShapeNode(rectOf: CGSize(width: hypot(deltaX, deltaY), height: CGFloat(radius) * 2))
      rectNode.strokeColor = strokeColor
      rectNode.fillColor = fillColor
      rectNode.zRotation = atan(deltaY / deltaX)
      rectNode.position = CGPoint(x: current.x + (deltaX / 2.0), y: current.y + (deltaY / 2.0))
      debugNode.addChild(rectNode)
    }
  }
}
