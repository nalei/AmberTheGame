import SpriteKit
import GameplayKit

class Skeleton: Enemy, RulesComponentDelegate {
  // MARK: - Initialization
  
  var targetPosition: vector_float2?
  
  required override init() {
    super.init()
    
    let spriteComponent = SpriteComponent(texture: SKTexture(imageNamed: "skeleton-idle"), size: CGSize(width: 260, height: 200))
    spriteComponent.node.anchorPoint = CGPoint(x: 0.5, y: 0.19)
    
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
    
    let physicsComponent = PhysicsComponent(
      physicsBody: SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 90), center: CGPoint(x: -5, y: 45)),
      colliderType: .ENEMY
    )
    physicsComponent.physicsBody.fieldBitMask = 0
    physicsComponent.physicsBody.mass = 0.50
    addComponent(physicsComponent)
    
    // Связываем `PhysicsComponent` и `SpriteComponent`.
    spriteComponent.node.physicsBody = physicsComponent.physicsBody
    
    addComponent(MovementComponent(
      walkSpeed: 80,
      maxJump: 0,
      accel: 20,
      decel: 80
    ))
    
    addComponent(AnimationComponent(
      idle: SKTexture(imageNamed: "skeleton-idle"),
      run: SKAction(named: "skeleton-run"),
      jumpUp: nil,
      jumpMiddle: nil,
      jumpDown: nil,
      hit: SKAction(named: "skeleton-attack"),
      damage: SKAction(named: "skeleton-damage")
    ))
    
    let attackComponent = AttackComponent(hp: 30)
    attackComponent.hitBox.position = CGPoint(x: 90, y: 40)
    attackComponent.hitBox.size = CGSize(width: 40, height: 80)
    attackComponent.hurtBox.position = CGPoint(x: -5, y: 45)
    attackComponent.hurtBox.size = CGSize(width: 40, height: 90)
    spriteComponent.node.addChild(attackComponent.hurtBox)
    addComponent(attackComponent)
    
    let intelligenceComponent = IntelligenceComponent(states: [
      AgentControlledState(entity: self),
      SkeletonMoveState(entity: self),
      SkeletonAttackState(entity: self)
    ])
    addComponent(intelligenceComponent)
    
    let agent = AgentComponent()
    agent.delegate = self
    agent.maxSpeed = 60
    agent.maxAcceleration = 40
    agent.mass = 0.05
    agent.radius = 40
    agent.behavior = GKBehavior()
    self.agentOffset = CGPoint(x: 15, y: 45)
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
    
    // Ряд ситуаций, в которых `Skeleton`, будет двигаться по направлению к `Amber`.
    let moveRaw = [
      // Amber находится на среднем расстоянии.
      ruleSystem.minimumGrade(forFacts: [
        Fact.amberMedium.rawValue as AnyObject,
      ])
    ]
    
    let move = moveRaw.reduce(0.0, max)
    
    // Ряд ситуаций, в которых `Skeleton`, будет наносить удар.
    let hitRaw = [
      // Amber находится на близком расстоянии.
      ruleSystem.minimumGrade(forFacts: [
        Fact.amberNear.rawValue as AnyObject
      ])
    ]
    
    let hit = hitRaw.reduce(0.0, max)
    
    if move >= hit && move > 0.0 {
      guard let amberAgent = state.amberTarget?.target.agent else { return }
      
      // Цель по направлению к которой будет двигаться 'Skeleton'
      targetPosition = amberAgent.position
      
      // Правила обеспечили мотивацию для движения по направлению к `Amber`.
      if let intelligenceComponent = component(ofType: IntelligenceComponent.self) {
        // Если объект находится в состоянии удара
        if intelligenceComponent.stateMachine.currentState is SkeletonAttackState {
          
        } else {
          intelligenceComponent.stateMachine.enter(SkeletonMoveState.self)
        }
      }
    } else if hit > move {
      // Правила обеспечили мотивацию для нанесения удара.
      if let intelligenceComponent = component(ofType: IntelligenceComponent.self) {
        intelligenceComponent.stateMachine.enter(SkeletonAttackState.self)
      }
    } else {
      // Правила не обеспечили никаких мотиваций.
      if let intelligenceComponent = component(ofType: IntelligenceComponent.self) {
        intelligenceComponent.stateMachine.enter(AgentControlledState.self)
      }
    }
    
  }
}
