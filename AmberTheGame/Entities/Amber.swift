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
  
  
  // MARK: - Initialization
  
  init(camera: SKCameraNode?, scene: SKScene) {
    agent = GKAgent2D()
    agent.radius = GameplayConfiguration.Amber.agentRadius
    agentOffset = CGPoint(x: 0, y: 33)
    
    super.init()
    
    let spriteComponent = SpriteComponent(texture: SKTexture(imageNamed: "amber-idle"), size: CGSize(width: 200, height: 200))
    spriteComponent.node.anchorPoint = CGPoint(x: 0.5, y: 0.31)
    
    // Свет вокруг персонажа
    let lightNode = SKLightNode()
    lightNode.position = CGPoint(
      x: spriteComponent.node.position.x,
      y: spriteComponent.node.position.y + 30)
    lightNode.categoryBitMask = 1
    lightNode.falloff = 5
    lightNode.lightColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
    lightNode.ambientColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    lightNode.name = "LightNode"
    spriteComponent.node.addChild(lightNode)
    
    addComponent(spriteComponent)
    
    addComponent(InputComponent(camera: camera, scene: scene))
    
    let physicsComponent = PhysicsComponent(
      physicsBody: SKPhysicsBody(rectangleOf: CGSize(width: 30 , height: 52), center: CGPoint(x: 0, y: 29)),
      colliderType: .PLAYER
    )
    physicsComponent.physicsBody.fieldBitMask = 0
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
      jumpDown: SKTexture(imageNamed: "amber-jump-down"),
      hit: SKAction(named: "amber-hit"),
      damage: SKAction(named: "amber-damage")
    ))
    
    let attackComponent = AttackComponent(hp: 3, states: [
      ReadyState(entity: self),
      AttackState(entity: self),
      DamagedState(entity: self)
    ])
    attackComponent.hitBox.position = CGPoint(x: 60, y: 30)
    attackComponent.hitBox.size = CGSize(width: 50, height: 50)
    attackComponent.hurtBox.position = CGPoint(x: 0, y: 29)
    attackComponent.hurtBox.size = CGSize(width: 30, height: 52)
    spriteComponent.node.addChild(attackComponent.hurtBox)
    addComponent(attackComponent)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - ResourceLoadableType
  
  static func loadResources() {
    ColliderType.definedCollisions[.PLAYER] = [
      .GROUND
    ]
    ColliderType.requestedContactNotifications[.PLAYER] = [
      .GROUND,
      .ENEMY
    ]
  }
  
  
  // MARK: - Convenience
  
  ///  Устанавливает агента в позицию спрайта (плюс смещение).
  func updateAgentPositionToMatchNodePosition() {
    // `spriteComponent` является вычисляемым свойством. Объявляем локальную версию, чтобы мы не вычисляли его несколько раз.
    let spriteComponent = self.spriteComponent
    
    agent.position = vector_float2(x: Float(spriteComponent.node.position.x + agentOffset.x), y: Float(spriteComponent.node.position.y + agentOffset.y))
    
    drawDebugAgent(color: SKColor.orange, radius: agent.radius)
  }
  
  
  // MARK: - Debug Path Drawing
  
  func drawDebugAgent(color: SKColor, radius: Float) {
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

