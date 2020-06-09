import SpriteKit
import GameplayKit

class LevelScene: SKScene {
  var entities = [GKEntity]()
  var graphs = [String : GKGraph]()
  
  // Playable character
  var character: Amber?
  
  // Update time
  var lastUpdateTimeInterval: TimeInterval = 0
  
  // Entity manager
  var entityManager: EntityManager!
  
  
  // MARK: - Pathfinding
  
  lazy var obstacleSpriteNodes: [SKSpriteNode] = self["Ground"] as! [SKSpriteNode]
  lazy var polygonObstacles: [GKPolygonObstacle] = []
  let graph = GKObstacleGraph(obstacles: [], bufferRadius: GameplayConfiguration.Enemy.pathfindingGraphBufferRadius)
  
  
  // MARK: - Pathfinding Debug
  
  var debugDrawingEnabled = false {
    didSet {
      debugDrawingEnabledDidChange()
    }
  }
  
  var graphLayer = SKNode()
  
  
  // MARK: - Scene Life Cycle
  
  override func didMove(to view: SKView) {
    super.didMove(to: view)
    
    self.lastUpdateTimeInterval = 0
    
    self.physicsWorld.contactDelegate = self
    
    entityManager = EntityManager(scene: self)
    
    // Создаем физическое тело для `ForegroundMap`
    if let foregroundMap = childNode(withName: "ForegroundMap") as? SKTileMapNode {
      giveTileMapPhysicsBody(tileMap: foregroundMap)
      obstacleSpriteNodes += foregroundMap["Ground"] as! [SKSpriteNode]
    }
    
    if let amberSprite = childNode(withName: "Amber") {
      // Создаем инстанс `Amber` entity
      character = Amber(camera: self.camera, scene: self, entityManager: entityManager)
      character!.spriteComponent.node.position = amberSprite.position
      character!.spriteComponent.node.name = amberSprite.name
      entityManager.add(character!)
      graphLayer.addChild(character!.debugNode)
      amberSprite.removeFromParent()
    }
    
    self["Goblin"].forEach { node in
      // Создаем инстанс`Goblin` entity
      let goblin = Goblin(entityManager: self.entityManager)
      goblin.spriteComponent.node.position = node.position
      goblin.spriteComponent.node.name = node.name
      self.entityManager.add(goblin)
      node.removeFromParent()
      
      //if let movementComponent = goblin.component(ofType: MovementComponent.self) {
      //  movementComponent.moveTo(.left)
      //}
    }
    
    self["Bat"].forEach { node in
      // Создаем инстанс `Bat` entity
      let bat = Bat(entityManager: self.entityManager)
      bat.spriteComponent.node.name = node.name
      bat.spriteComponent.node.position = node.position
      bat.spriteComponent.node.run(SKAction(named: "bat-fly")!, withKey: "fly")
      self.entityManager.add(bat)
      node.removeFromParent()
    }
    
    self["ParallaxBg"].forEach { node in
      if let parralaxBgSprite = node as? SKSpriteNode {
        // Создаем инстанс `ParallaxBg` entity
        let parralaxBg = ParallaxBg(spriteNode: parralaxBgSprite, camera: self.camera)
        self.entityManager.add(parralaxBg)
      }
    }
    
    // Добавляем препятствия в граф поиска пути
    polygonObstacles += SKNode.obstacles(fromNodeBounds: obstacleSpriteNodes)
    graph.addObstacles(polygonObstacles)
    
    #if DEBUG
    self.addChild(graphLayer)
    
    debugDrawingEnabled = true
    
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
  
  override func didFinishUpdate() {
    /*
     Обновляем позицию агента, чтобы она соответствовала позиции `Amber`.
     Это гарантирует, что агент находится в допустимом местоположении в начале следующего фрейма.
     */
    character?.updateAgentPositionToMatchNodePosition()
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
    
    //    let collision: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    //    if collision == CollisionCategory.ENEMY | CollisionCategory.GROUND {
    //      if let movementComponent = contact.bodyA.node?.entity?.component(ofType: MovementComponent.self) {
    //        if collisionDirection(contact) == .left && movementComponent.facing == .left {
    //          movementComponent.moveTo(.right)
    //        }
    //        if collisionDirection(contact) == .right && movementComponent.facing == .right {
    //          movementComponent.moveTo(.left)
    //        }
    //      } else if let movementComponent = contact.bodyB.node?.entity?.component(ofType: MovementComponent.self) {
    //        if collisionDirection(contact) == .left && movementComponent.facing == .left {
    //          movementComponent.moveTo(.right)
    //        }
    //        if collisionDirection(contact) == .right && movementComponent.facing == .right {
    //          movementComponent.moveTo(.left)
    //        }
    //      }
    //    }
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
