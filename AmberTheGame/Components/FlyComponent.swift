import SpriteKit
import GameplayKit

class FlyComponent: GKAgent2D, GKAgentDelegate {
  let entityManager: EntityManager
  var debugNode = SKNode()
  var shift = CGPoint(x: 0, y: 0)
  
  init(maxSpeed: Float, maxAcceleration: Float, radius: Float, entityManager: EntityManager) {
    self.entityManager = entityManager
    super.init()
    delegate = self
    self.maxSpeed = maxSpeed
    self.maxAcceleration = maxAcceleration
    self.radius = radius
    self.mass = 0.01
    
    drawDebugPath(color: SKColor.orange, radius: radius) // Debug!!!!!
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// Прежде чем агент обновит позицию, устанавливаем агента в позицию спрайта
  func agentWillUpdate(_ agent: GKAgent) {
    guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
      return
    }
    
    position = vector_float2(CGPoint(x: spriteComponent.node.position.x + shift.x, y: spriteComponent.node.position.y + shift.y))
  }
  
  /// После того, как агент обновит позицию, устанавливаем спрайт в позицию агента
  func agentDidUpdate(_ agent: GKAgent) {
    guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
      return
    }
    
    spriteComponent.node.position = CGPoint(x: CGFloat(position.x) - shift.x, y: CGFloat(position.y) - shift.y)
    
    debugNode.position = CGPoint(position) // Debug!!!!!
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    guard let target = entityManager.getAmberAgent() else {
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
    behavior = EnemyMoveBehavior(targetSpeed: maxSpeed, seek: target, avoid: alliedFlyComponents)
  }

  
  // MARK: - Debug Path Drawing
  
  func drawDebugPath(color: SKColor, radius: Float) {
    debugNode.removeAllChildren()
    
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    // Use RGB component accessor common between `UIColor` and `NSColor`.
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    let strokeColor = SKColor(red: red, green: green, blue: blue, alpha: 0.4)
    let fillColor = SKColor(red: red, green: green, blue: blue, alpha: 0.2)
    
    let circleNode = SKShapeNode(circleOfRadius: CGFloat(radius))
    circleNode.strokeColor = strokeColor
    circleNode.fillColor = fillColor
    circleNode.position = CGPoint(position)
    debugNode.addChild(circleNode)
  }
}
