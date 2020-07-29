import SpriteKit
import GameplayKit

class Bat: Enemy, RulesComponentDelegate {
  // MARK: - Initialization
  
  required init(patrolPoints: [CGPoint]) {
    super.init()
    
    let spriteComponent = SpriteComponent(texture: SKTexture(imageNamed: "bat-idle"), size: CGSize(width: 64, height: 64))
    addComponent(spriteComponent)
    
    let physicsComponent = PhysicsComponent(physicsBody: SKPhysicsBody(rectangleOf: CGSize(width: 30, height: 30), center: CGPoint(x: 0, y: 10)))
    physicsComponent.physicsBody.categoryBitMask = CollisionCategory.ENEMY
    physicsComponent.physicsBody.collisionBitMask = CollisionCategory.GROUND
    physicsComponent.physicsBody.fieldBitMask = 0
    physicsComponent.physicsBody.mass = 0.10
    physicsComponent.physicsBody.affectedByGravity = false
    addComponent(physicsComponent)
    
    // Связываем `PhysicsComponent` и `SpriteComponent`.
    spriteComponent.node.physicsBody = physicsComponent.physicsBody
    
    let attackComponent = AttackComponent()
    attackComponent.hitBox.position = CGPoint(x: 0, y: 10)
    attackComponent.hitBox.size = CGSize(width: 30, height: 30)
    attackComponent.hurtBox.position = CGPoint(x: 0 , y: 10)
    attackComponent.hurtBox.size = CGSize(width: 30, height: 30)
    spriteComponent.node.addChild(attackComponent.hurtBox)
    addComponent(attackComponent)
    
    let agent = AgentComponent()
    agent.delegate = self
    agent.maxSpeed = 300
    agent.maxAcceleration = 40
    agent.mass = 0.03
    agent.radius = 25
    agent.behavior = GKBehavior()
    self.agentOffset = CGPoint(x: 0, y: 10)
    self.patrolPoints = patrolPoints
    
    /*
     `GKAgent2D` является подклассом `GKComponent`. Добавляем его в список компонентов `Enemy`,
     чтобы он был обновлен на каждом цикле обновления компонентов.
     */
    addComponent(agent)
    
    let rulesComponent = RulesComponent(rules: [
      PlayerBotNearRule(),
      PlayerBotMediumRule(),
      PlayerBotFarRule()
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
    
    
  }
  
}
