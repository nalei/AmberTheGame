import SpriteKit
import GameplayKit

class Skeleton: Enemy, RulesComponentDelegate {
  // MARK: - Initialization
  
  var targetPosition: vector_float2?
  
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
    
    addComponent(MovementComponent(
      walkSpeed: 60,
      maxJump: 0,
      accel: 40,
      decel: 80
    ))
    
    addComponent(AnimationComponent(
      idle: SKTexture(imageNamed: "skeleton-idle"),
      run: SKAction(named: "skeleton-run"),
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
    
    let intelligenceComponent = IntelligenceComponent(states: [
      AgentControlledState(entity: self),
      SkeletonMoveState(entity: self)
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
        intelligenceComponent.stateMachine.enter(SkeletonMoveState.self)
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
