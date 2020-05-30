import SpriteKit
import GameplayKit

class FlyComponent: GKAgent2D, GKAgentDelegate {
  let entityManager: EntityManager
  
  var debugNode = SKNode()
  
  init(maxSpeed: Float, maxAcceleration: Float, radius: Float, entityManager: EntityManager) {
    self.entityManager = entityManager
    super.init()
    delegate = self
    self.maxSpeed = maxSpeed
    self.maxAcceleration = maxAcceleration
    self.radius = radius
    self.mass = 0.01
    
    //    drawDebugPath(color: SKColor.orange, radius: radius) // Debug!!!!!
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// Прежде чем агент обновит позицию, устанавливаем агента в позицию спрайта
  func agentWillUpdate(_ agent: GKAgent) {
    guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
      return
    }
    
    position = vector_float2(spriteComponent.node.position)
  }
  
  /// После того, как агент обновит позицию, устанавливаем спрайт в позицию агента
  func agentDidUpdate(_ agent: GKAgent) {
    guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
      return
    }
    
    spriteComponent.node.position = CGPoint(position)
    
    debugNode.position = CGPoint(position) // Debug!!!!!
  }
  
  /// Возвращает FlyComponent игрока
  func getAmberFlyComponent() -> GKAgent2D? {
    let playerEntity = entityManager.getAmberEntity()
    return playerEntity?.component(ofType: FlyComponent.self)
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    guard let targetFlyComponent = getAmberFlyComponent() else {
      return
    }
    
    let alliedFlyComponents = entityManager.getAllFlyComponents()
    
    if let spriteComponent = entity?.component(ofType: SpriteComponent.self) {
      if velocity.x < 0 {
        spriteComponent.node.xScale = -1
      }
      if velocity.x > 0 {
        spriteComponent.node.xScale = 1
      }
    }
    
    // Поведение
    behavior = EnemyMoveBehavior(targetSpeed: maxSpeed, seek: targetFlyComponent, avoid: alliedFlyComponents)
  }
  
  // MARK: - Debug Path Drawing
  
  func drawDebugPath(path: [CGPoint], color: SKColor, radius: Float) {
    guard path.count > 1 else { return }
    
    debugNode.removeAllChildren()
    
    var drawPath = path
    
    drawPath += [drawPath.first!]
    
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    // Use RGB component accessor common between `UIColor` and `NSColor`.
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    let strokeColor = SKColor(red: red, green: green, blue: blue, alpha: 0.4)
    let fillColor = SKColor(red: red, green: green, blue: blue, alpha: 0.2)
    
//    for index in 0..<drawPath.count - 1 {
//      let current = CGPoint(x: drawPath[index].x, y: drawPath[index].y)
//      let next = CGPoint(x: drawPath[index + 1].x, y: drawPath[index + 1].y)
//
//      let circleNode = SKShapeNode(circleOfRadius: CGFloat(radius))
//      circleNode.strokeColor = strokeColor
//      circleNode.fillColor = fillColor
//      circleNode.position = current
//      debugNode.addChild(circleNode)
//
//      let deltaX = next.x - current.x
//      let deltaY = next.y - current.y
//      let rectNode = SKShapeNode(rectOf: CGSize(width: hypot(deltaX, deltaY), height: CGFloat(radius) * 2))
//      rectNode.strokeColor = strokeColor
//      rectNode.fillColor = fillColor
//      rectNode.zRotation = atan(deltaY / deltaX)
//      rectNode.position = CGPoint(x: current.x + (deltaX / 2.0), y: current.y + (deltaY / 2.0))
//      debugNode.addChild(rectNode)
//    }
//
    let circleNode = SKShapeNode(circleOfRadius: CGFloat(radius))
    circleNode.strokeColor = strokeColor
    circleNode.fillColor = fillColor
    circleNode.position = CGPoint(position)
    debugNode.addChild(circleNode)
  }
}


// MARK: - Points and vectors

extension CGPoint {
  init(_ point: vector_float2) {
    self.init()
    x = CGFloat(point.x)
    y = CGFloat(point.y)
  }
}

extension vector_float2 {
  init(_ point: CGPoint) {
    self.init(x: Float(point.x), y: Float(point.y))
  }
}
