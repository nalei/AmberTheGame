import SpriteKit
import GameplayKit

class Goblin: Enemy {
  // MARK: - Initialization
  
  required override init() {
    super.init()
    
    let spriteComponent = SpriteComponent(texture: SKTexture(imageNamed: "goblin-idle"), size: CGSize(width: 100, height: 100))
    spriteComponent.node.anchorPoint = CGPoint(x: 0.5, y: 0)
    addComponent(spriteComponent)
    
    let physicsComponent = PhysicsComponent(
      physicsBody: SKPhysicsBody(rectangleOf: CGSize(width: 42, height: 50), center: CGPoint(x: 0, y: 25)),
      colliderType: .ENEMY
    )
    physicsComponent.physicsBody.fieldBitMask = 0
    physicsComponent.physicsBody.mass = 0.20
    addComponent(physicsComponent)
    
    // Связываем `PhysicsComponent` и `SpriteComponent`.
    spriteComponent.node.physicsBody = physicsComponent.physicsBody
    
    addComponent(MovementComponent())
    
    let animationComponent = AnimationComponent(states: [
      IdleState(entity: self, idleAnimation: SKTexture(imageNamed: "goblin-idle")),
      WalkingState(entity: self, walkingAnimation: SKAction(named: "goblin-run")),
    ])
    addComponent(animationComponent)
    
    let agent = AgentComponent()
    agent.delegate = self
    agent.maxSpeed = 200
    agent.maxAcceleration = 300
    agent.mass = 0.03
    agent.radius = 35
    agent.behavior = GKBehavior()
    self.agentOffset = CGPoint(x: 0, y: 25)
    addComponent(agent)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
