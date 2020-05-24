import SpriteKit
import GameplayKit

class LevelScene: SKScene {
  var entities = [GKEntity]()
  var graphs = [String : GKGraph]()
  
  // Playable character
  var character: GKEntity?
  
  // Update time
  var lastUpdateTimeInterval: TimeInterval = 0
  
  // Entity manager
  var entityManager: EntityManager!
  
  
  // MARK: - Pathfinding
  
  let graph = GKObstacleGraph(obstacles: [], bufferRadius: 60.0)
  lazy var obstacleSpriteNodes: [SKSpriteNode] = self["Idol"] as! [SKSpriteNode]
  lazy var polygonObstacles: [GKPolygonObstacle] = SKNode.obstacles(fromNodePhysicsBodies: self.obstacleSpriteNodes)
  
  
  // MARK: - Pathfinding Debug
  
  var debugDrawingEnabled = false {
    didSet {
      debugDrawingEnabledDidChange()
    }
  }
  
  var graphLayer = SKNode()
  var debugObstacleLayer = SKNode()
  
  
  // MARK: - Scene Life Cycle
  
  override func didMove(to view: SKView) {
    super.didMove(to: view)
    
    self.lastUpdateTimeInterval = 0
    
    self.physicsWorld.contactDelegate = self
    
    // Добавляем препятствия в граф поиска пути
    graph.addObstacles(polygonObstacles)
    
    // Создаем инстанс `EntityManager` entity
    entityManager = EntityManager(scene: self, obstacles: polygonObstacles)
    
    // Создаем физическое тело для `ForegroundMap`
    if let foregroundMap = childNode(withName: "ForegroundMap") as? SKTileMapNode {
      giveTileMapPhysicsBody(tileMap: foregroundMap)
    }
    
    if let amberSprite = childNode(withName: "Amber") as? SKSpriteNode {
      
      // Создаем инстанс `Amber` entity
      character = Amber(camera: self.camera, scene: self, entityManager: entityManager)
      entityManager.add(character!)
      
      if let spriteComponent = character?.component(ofType: SpriteComponent.self) {
        spriteComponent.node.position = amberSprite.position
        spriteComponent.node.name = amberSprite.name
        amberSprite.removeFromParent()
      }
    }
    
    enumerateChildNodes(withName: "Goblin") { node, _ in
      
      // Создаем инстанс`Goblin` entity
      let goblin = Goblin(entityManager: self.entityManager)
      self.entityManager.add(goblin)
      
      if let spriteComponent = goblin.component(ofType: SpriteComponent.self) {
        spriteComponent.node.position = node.position
        spriteComponent.node.name = node.name
        node.removeFromParent()
      }
      
      if let movementComponent = goblin.component(ofType: MovementComponent.self) {
        movementComponent.moveTo(.left)
      }
    }
    
    enumerateChildNodes(withName: "Bat") { node, _ in
      
      // Создаем инстанс `Bat` entity
      let bat = Bat(entityManager: self.entityManager)
      self.entityManager.add(bat)
      
      if let spriteComponent = bat.component(ofType: SpriteComponent.self) {
        spriteComponent.node.position = node.position
        spriteComponent.node.name = node.name
        node.removeFromParent()
        spriteComponent.node.run(SKAction(named: "bat-fly")!, withKey: "fly")
      }
    }
    
    enumerateChildNodes(withName: "ParallaxBg") { node, _ in
      if let parralaxBgSprite = node as? SKSpriteNode {
        
        // Создаем инстанс `ParallaxBg` entity
        let parralaxBg = ParallaxBg(spriteNode: parralaxBgSprite, camera: self.camera)
        self.entityManager.add(parralaxBg)
      }
    }
    
    // Добавляем отладочные слои на сцену
    self.addChild(graphLayer)
    self.addChild(debugObstacleLayer)
    
    #if DEBUG
    debugDrawingEnabled = !debugDrawingEnabled

    view.showsPhysics   = debugDrawingEnabled
    view.showsFPS       = debugDrawingEnabled
    view.showsNodeCount = debugDrawingEnabled
    view.showsDrawCount = debugDrawingEnabled
    #endif
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
    
    // Инициализируем `lastUpdateTime`, если ешё не был инициализирован
    if (self.lastUpdateTimeInterval == 0) {
      self.lastUpdateTimeInterval = currentTime
    }
    
    // Рассчитываем время с момента последнего обновления
    let deltaTime = currentTime - self.lastUpdateTimeInterval
    self.lastUpdateTimeInterval = currentTime
    
    entityManager.update(deltaTime: deltaTime)
  }
}




//MARK: - Physics

extension LevelScene: SKPhysicsContactDelegate {
  
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
