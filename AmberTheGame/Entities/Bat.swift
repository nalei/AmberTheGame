import SpriteKit
import GameplayKit

class Bat: Enemy {
  // MARK: - Initialization
  
  required init(patrolPoints: [CGPoint], entityManager: EntityManager) {
    super.init()
    
    let spriteComponent = SpriteComponent(texture: SKTexture(imageNamed: "bat-idle"), size: CGSize(width: 65, height: 65))
    addComponent(spriteComponent)
    
    let physicsComponent = PhysicsComponent(physicsBody: SKPhysicsBody(rectangleOf: CGSize(width: 30, height: 30), center: CGPoint(x: 0, y: 10)))
    physicsComponent.physicsBody.categoryBitMask = CollisionCategory.ENEMY
    physicsComponent.physicsBody.collisionBitMask = CollisionCategory.GROUND
    physicsComponent.physicsBody.mass = 0.10
    physicsComponent.physicsBody.affectedByGravity = false
    addComponent(physicsComponent)

    // Связываем `PhysicsComponent` и `SpriteComponent`.
    spriteComponent.node.physicsBody = physicsComponent.physicsBody
    
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
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
