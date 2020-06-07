import SpriteKit
import GameplayKit

class Amber: GKEntity {
  // MARK: - Properties
  
  /// Агент, используемый как цель при поиске пути.
  let agent: GKAgent2D
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = component(ofType: SpriteComponent.self) else { fatalError("A Enemy must have an SpriteComponent.") }
    return spriteComponent
  }
  
  /// Используется для смещения положения агента относительно центра спрайта
  var agentOffset = CGPoint.zero
  
  /// Используется для фигур, представляющих текущий путь для отладочной отрисовки.
  var debugNode = SKNode()
  
  init(camera: SKCameraNode?, scene: SKScene, entityManager: EntityManager) {
    agent = GKAgent2D()
    agent.radius = GameplayConfiguration.Amber.agentRadius
    agentOffset = CGPoint(x: 0, y: 30)
    
    super.init()
    
    let spriteComponent = SpriteComponent(texture: SKTexture(imageNamed: "amber-idle"), size: CGSize(width: 100, height: 100))
    spriteComponent.node.anchorPoint = CGPoint(x: 0.5, y: 0)
    addComponent(spriteComponent)
    
    addComponent(InputComponent(camera: camera, scene: scene))
    
    let physicsComponent = PhysicsComponent(physicsBody: SKPhysicsBody(rectangleOf: CGSize(width: 42, height: 64), center: CGPoint(x: 0, y: 30)))
    physicsComponent.physicsBody.categoryBitMask = CollisionCategory.PLAYER
    physicsComponent.physicsBody.collisionBitMask = CollisionCategory.GROUND
    physicsComponent.physicsBody.contactTestBitMask = CollisionCategory.GROUND
    physicsComponent.physicsBody.mass = 0.15
    addComponent(physicsComponent)
    
    // Связываем `PhysicsComponent` и `SpriteComponent`.
    spriteComponent.node.physicsBody = physicsComponent.physicsBody
    
    addComponent(MovementComponent())
    
    addComponent(AnimationComponent(
      idle: SKTexture(imageNamed: "amber-idle"),
      run: SKAction(named: "amber-run"),
      jumpUp: SKTexture(imageNamed: "amber-jump-up"),
      jumpMiddle: SKTexture(imageNamed: "amber-jump-middle"),
      jumpDown: SKTexture(imageNamed: "amber-jump-down")
    ))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Convenience
  
  ///  Устанавливает агента в позицию спрайта (плюс смещение).
  func updateAgentPositionToMatchNodePosition() {
    // `spriteComponent` является вычисляемым свойством. Объявляем локальную версию, чтобы мы не вычисляли его несколько раз.
    let spriteComponent = self.spriteComponent
    
    agent.position = vector_float2(x: Float(spriteComponent.node.position.x + agentOffset.x), y: Float(spriteComponent.node.position.y + agentOffset.y))
    
    drawDebugPath(color: SKColor.orange, radius: agent.radius)
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
    circleNode.position = CGPoint(agent.position)
    debugNode.addChild(circleNode)
  }
}

