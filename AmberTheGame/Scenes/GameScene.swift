import SpriteKit
import GameplayKit

class GameScene: SKScene {
  var entities = [GKEntity]()
  var graphs = [String : GKGraph]()
  
  var lastUpdateTimeInterval: TimeInterval = 0
  var entityManager: EntityManager!
  var character: GKEntity?
  
  
  // MARK: - Scene Life Cycle
  
  override func sceneDidLoad() {
    self.lastUpdateTimeInterval = 0
  }
  
  override func didMove(to view: SKView) {
    self.physicsWorld.contactDelegate = self
    
    entityManager = EntityManager(scene: self, camera: camera)
    
    for entity in self.entities {
      entityManager.add(entity)
    }
    
    if let foregroundMap = childNode(withName: "ForegroundMap") as? SKTileMapNode {
      giveTileMapPhysicsBody(tileMap: foregroundMap)
    }
    
    if let amberSprite = childNode(withName: "Amber") as? SKSpriteNode, let camera = self.camera {
      // Create instance of Amber entity
      character = Amber(camera: camera, scene: self, entityManager: entityManager)
      entityManager.add(character!)
      
      if let spriteComponent = character?.component(ofType: SpriteComponent.self) {
        spriteComponent.node.position = amberSprite.position
        spriteComponent.node.name = amberSprite.name
        amberSprite.removeFromParent()
      }
    }
    
    if let goblinSprite = childNode(withName: "Goblin") as? SKSpriteNode {
      // Create instance of Goblin entity
      let goblin = Goblin(entityManager: entityManager)
      entityManager.add(goblin)
      
      if let spriteComponent = goblin.component(ofType: SpriteComponent.self) {
        spriteComponent.node.position = goblinSprite.position
        spriteComponent.node.name = goblinSprite.name
        goblinSprite.removeFromParent()
      }
    }
  }
  
  // Camera action
  override func didSimulatePhysics() {
    guard let camera = self.camera else { return }
    if let spriteComponent = character?.component(ofType: SpriteComponent.self) {
      camera.run(SKAction.move(
        to: CGPoint(
          x: spriteComponent.node.position.x,
          y: spriteComponent.node.position.y),
        duration: 0.2)
      )
    }
  }
  
  // Called before each frame is rendered
  override func update(_ currentTime: TimeInterval) {
    
    // Initialize _lastUpdateTime if it has not already been
    if (self.lastUpdateTimeInterval == 0) {
      self.lastUpdateTimeInterval = currentTime
    }
    
    // Calculate time since last update
    let deltaTime = currentTime - self.lastUpdateTimeInterval
    self.lastUpdateTimeInterval = currentTime
    
    entityManager.update(deltaTime: deltaTime)
  }
}


//MARK: - Physics

extension GameScene: SKPhysicsContactDelegate {
  
  func didBegin(_ contact: SKPhysicsContact) {
    
    if contact.bodyA.categoryBitMask == CollisionCategory.GROUND || contact.bodyB.categoryBitMask == CollisionCategory.GROUND {
      if collisionDirection(contact) == .Bottom {
        if let movementComponent = contact.bodyA.node?.entity?.component(ofType: MovementComponent.self) {
          movementComponent.onGround = true
        } else if let movementComponent = contact.bodyB.node?.entity?.component(ofType: MovementComponent.self) {
          movementComponent.onGround = true
        }
      }
    }
  }
  
  private func collisionDirection(_ contact: SKPhysicsContact) -> Collision.Direction {
    if contact.contactNormal.dy > 0.9 && contact.contactNormal.dy <= 1 {
      return .Bottom
    }
    return .None
  }
}
