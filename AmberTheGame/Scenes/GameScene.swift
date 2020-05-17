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
      
      /// Создаем инстанс `Amber` entity
      character = Amber(camera: camera, scene: self, entityManager: entityManager)
      entityManager.add(character!)
      
      if let spriteComponent = character?.component(ofType: SpriteComponent.self) {
        spriteComponent.node.position = amberSprite.position
        spriteComponent.node.name = amberSprite.name
        amberSprite.removeFromParent()
      }
    }
    
    enumerateChildNodes(withName: "Goblin") { node, _ in
      if let goblinSprite = node as? SKSpriteNode {

        /// Создаем инстанс`Goblin` entity
        let goblin = Goblin(entityManager: self.entityManager)
        self.entityManager.add(goblin)
        
        if let spriteComponent = goblin.component(ofType: SpriteComponent.self) {
          spriteComponent.node.position = goblinSprite.position
          spriteComponent.node.name = goblinSprite.name
          goblinSprite.removeFromParent()
        }
        
        if let movementComponent = goblin.component(ofType: MovementComponent.self) {
          movementComponent.moveTo(.left)
        }
      }
    }
    
    enumerateChildNodes(withName: "Bat") { node, _ in
      if let batSprite = node as? SKSpriteNode {
        
        /// Создаем инстанс`Bat` entity
        let bat = Bat(entityManager: self.entityManager)
        self.entityManager.add(bat)
        
        if let spriteComponent = bat.component(ofType: SpriteComponent.self) {
          spriteComponent.node.position = batSprite.position
          spriteComponent.node.name = batSprite.name
          batSprite.removeFromParent()
          spriteComponent.node.run(SKAction(named: "bat-fly")!, withKey: "fly")
        }
      }
    }
  }
  
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
  
  override func update(_ currentTime: TimeInterval) {
    
    /// Инициализируем `lastUpdateTime`, если ешё не был инициализирован
    if (self.lastUpdateTimeInterval == 0) {
      self.lastUpdateTimeInterval = currentTime
    }
    
    /// Рассчитываем время с момента последнего обновления
    let deltaTime = currentTime - self.lastUpdateTimeInterval
    self.lastUpdateTimeInterval = currentTime
    
    entityManager.update(deltaTime: deltaTime)
  }
}


//MARK: - Physics

extension GameScene: SKPhysicsContactDelegate {
  
  func didBegin(_ contact: SKPhysicsContact) {
    
    if contact.bodyA.categoryBitMask == CollisionCategory.GROUND || contact.bodyB.categoryBitMask == CollisionCategory.GROUND {
      if collisionDirection(contact) == .bottom {
        if let movementComponent = contact.bodyA.node?.entity?.component(ofType: MovementComponent.self) {
          movementComponent.onGround = true
        } else if let movementComponent = contact.bodyB.node?.entity?.component(ofType: MovementComponent.self) {
          movementComponent.onGround = true
        }
      }
    }
    
    let collision: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    if collision == CollisionCategory.ENEMY | CollisionCategory.GROUND {
      if let movementComponent = contact.bodyA.node?.entity?.component(ofType: MovementComponent.self) {
        if collisionDirection(contact) == .left && movementComponent.facing == .left {
          movementComponent.moveTo(.right)
        }
        if collisionDirection(contact) == .right && movementComponent.facing == .right {
          movementComponent.moveTo(.left)
        }
      } else if let movementComponent = contact.bodyB.node?.entity?.component(ofType: MovementComponent.self) {
        if collisionDirection(contact) == .left && movementComponent.facing == .left {
          movementComponent.moveTo(.right)
        }
        if collisionDirection(contact) == .right && movementComponent.facing == .right {
          movementComponent.moveTo(.left)
        }
      }
    }
    
  }
  
  private func collisionDirection(_ contact: SKPhysicsContact) -> CollisionCategory.Direction {
    if contact.contactNormal.dy > 0.9 && contact.contactNormal.dy <= 1 {
      return .bottom
    }
    if contact.contactNormal.dx == 1 {
      return .left
    }
    if contact.contactNormal.dx == -1 {
      return .right
    }
    return .none
  }
}
