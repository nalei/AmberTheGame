import SpriteKit
import GameplayKit

class Skeleton: Enemy, RulesComponentDelegate {
  // MARK: - Initialization
  
  required override init() {
    super.init()
    
    let spriteComponent = SpriteComponent(texture: SKTexture(imageNamed: "skeleton-idle"), size: CGSize(width: 200, height: 200))
    spriteComponent.node.anchorPoint = CGPoint(x: 0.5, y: 0.18)
    addComponent(spriteComponent)
    
    let physicsComponent = PhysicsComponent(physicsBody: SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 90), center: CGPoint(x: -15, y: 45)))
    physicsComponent.physicsBody.categoryBitMask = CollisionCategory.ENEMY
    physicsComponent.physicsBody.collisionBitMask = CollisionCategory.GROUND
    physicsComponent.physicsBody.contactTestBitMask = CollisionCategory.GROUND
    physicsComponent.physicsBody.fieldBitMask = 0
    physicsComponent.physicsBody.mass = 0.50
    addComponent(physicsComponent)

    // Связываем `PhysicsComponent` и `SpriteComponent`.
    spriteComponent.node.physicsBody = physicsComponent.physicsBody
    
    addComponent(MovementComponent())
    
    addComponent(AnimationComponent(
      idle: SKTexture(imageNamed: "skeleton-idle"),
      run: nil,
      jumpUp: nil,
      jumpMiddle: nil,
      jumpDown: nil,
      hit: nil,
      damage: SKAction(named: "skeleton-damage")
    ))
    
    let attackComponent = AttackComponent()
    attackComponent.hitBox.position = CGPoint(x: 60, y: 30)
    attackComponent.hitBox.size = CGSize(width: 50, height: 50)
    attackComponent.hurtBox.position = CGPoint(x: -15, y: 45)
    attackComponent.hurtBox.size = CGSize(width: 40, height: 90)
    spriteComponent.node.addChild(attackComponent.hurtBox)
    addComponent(attackComponent)
    
    let intelligenceComponent = IntelligenceComponent()
    addComponent(intelligenceComponent)
    
    let agent = AgentComponent()
    agent.delegate = self
    agent.maxSpeed = 250
    agent.maxAcceleration = 30
    agent.mass = 0.05
    agent.radius = 25
    agent.behavior = GKBehavior()
    self.agentOffset = CGPoint(x: 0, y: 10)
    
    /*
     `GKAgent2D` является подклассом `GKComponent`. Добавляем его в список компонентов `Enemy`,
     чтобы он был обновлен на каждом цикле обновления компонентов.
     */
    addComponent(agent)
    
    let rulesComponent = RulesComponent(rules: [
      AmberNearRule(),
      AmberMediumRule(),
      AmberFarRule()
    ])
    addComponent(rulesComponent)
    rulesComponent.delegate = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - RulesComponentDelegate
  
  func rulesComponent(rulesComponent: RulesComponent, didFinishEvaluatingRuleSystem ruleSystem: GKRuleSystem) {
    let state = ruleSystem.state["snapshot"] as! EntitySnapshot
    
    // Определяем `mandate` на основе результата оценки правил.
    
    // Ряд ситуаций, в которых `Enemy`, будет охотиться на `Amber`.
    let huntAmberRaw = [
      
      // Amber находится на близком расстоянии.
      ruleSystem.minimumGrade(forFacts: [
        Fact.amberNear.rawValue as AnyObject
      ]),
      
      // Amber находится на среднем расстоянии.
      ruleSystem.minimumGrade(forFacts: [
        Fact.amberMedium.rawValue as AnyObject,
      ])
    ]
    
    // Find the maximum of the minima from above.
    let huntAmber = huntAmberRaw.reduce(0.0, max)
    
    if huntAmber > 0.0 {
      // Правила обеспечили мотивацию для охоты на `Amber`.
      if let intelligenceComponent = component(ofType: IntelligenceComponent.self) {
        intelligenceComponent.stateMachine.enter(AgentControlledState.self)
      }
      guard let amberAgent = state.amberTarget?.target.agent else { return }
      mandate = .huntAgent(amberAgent)
    } else {
      
    }
  }
}
