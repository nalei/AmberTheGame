import SpriteKit
import GameplayKit

class Bat: Enemy, RulesComponentDelegate {
  // MARK: - Properties
  
  var nestPoint: CGPoint?
  
  
  // MARK: - Initialization
  
  required init(patrolPoints: [CGPoint], nestPoint: CGPoint) {
    super.init()
    
    let spriteComponent = SpriteComponent(texture: SKTexture(imageNamed: "bat-idle"), size: CGSize(width: 64, height: 64))
    addComponent(spriteComponent)
    
    let physicsComponent = PhysicsComponent(
      physicsBody: SKPhysicsBody(rectangleOf: CGSize(width: 30, height: 30), center: CGPoint(x: 0, y: 10)),
      colliderType: .ENEMY
    )
    physicsComponent.physicsBody.fieldBitMask = 0
    physicsComponent.physicsBody.mass = 0.10
    physicsComponent.physicsBody.affectedByGravity = false
    addComponent(physicsComponent)
    
    // Связываем `PhysicsComponent` и `SpriteComponent`.
    spriteComponent.node.physicsBody = physicsComponent.physicsBody
    
    let healthComponent = HealthComponent(hp: 1)
    healthComponent.hitBox.position = CGPoint(x: 0, y: 10)
    healthComponent.hitBox.size = CGSize(width: 30, height: 30)
    healthComponent.hurtBox.position = CGPoint(x: 0 , y: 10)
    healthComponent.hurtBox.size = CGSize(width: 30, height: 30)
    spriteComponent.node.addChild(healthComponent.hurtBox)
    addComponent(healthComponent)
    
    let animationComponent = AnimationComponent(states: [
      IdleState(entity: self, idleAnimation: SKTexture(imageNamed: "bat-idle")),
      WalkingState(entity: self, walkingAnimation: SKAction(named: "bat-fly")),
      DamageState(entity: self, damageAnimation: SKAction(named: "bat-died"))
    ])
    addComponent(animationComponent)
    
    let intelligenceComponent = IntelligenceComponent(states: [
      BatSleepState(entity: self),
      AgentControlledState(entity: self)
    ])
    addComponent(intelligenceComponent)
    
    let agent = AgentComponent()
    agent.delegate = self
    agent.maxSpeed = 300
    agent.maxAcceleration = 30
    agent.mass = 0.05
    agent.radius = 25
    agent.behavior = GKBehavior()
    self.agentOffset = CGPoint(x: 0, y: 10)
    self.patrolPoints = patrolPoints
    addComponent(agent)
    
    let rulesComponent = RulesComponent(rules: [
      AmberNearRule(),
      AmberMediumRule(),
      AmberFarRule()
    ])
    addComponent(rulesComponent)
    rulesComponent.delegate = self
    self.nestPoint = nestPoint
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - RulesComponentDelegate
  
  func rulesComponent(rulesComponent: RulesComponent, didFinishEvaluatingRuleSystem ruleSystem: GKRuleSystem) {
    let state = ruleSystem.state["snapshot"] as! EntitySnapshot
    
    // Определяем `mandate` на основе результата оценки правил.
    
    // Ряд ситуаций, в которых `Bat`, будет охотиться на `Amber`.
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
    
    let huntAmber = huntAmberRaw.reduce(0.0, max)
    
    if huntAmber > 0.0 {
      // Правила обеспечили мотивацию для охоты на `Amber`.
      guard let amberAgent = state.amberTarget?.target.agent else { return }
      mandate = .huntAgent(amberAgent)
      
      if let intelligenceComponent = component(ofType: IntelligenceComponent.self) {
        intelligenceComponent.stateMachine.enter(AgentControlledState.self)
      }
      
      if let animationComponent = component(ofType: AnimationComponent.self) {
        animationComponent.stateMachine.enter(WalkingState.self)
      }
    } else {
      /*
       Правила не обеспечили мотивации для охоты, поэтому `Bat` возврвщается к `nestPoint`,
       (если мандат в состоянии `.passiveAgent` значит уже спит).
       */
      switch mandate {
      case .passiveAgent:
        break
      default:
        guard let nestPoint = self.nestPoint else { return }
        mandate = .returnToPosition(vector_float2(nestPoint))
      }
    }
  }
}
