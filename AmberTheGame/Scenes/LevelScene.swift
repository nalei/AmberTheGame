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
  
  lazy var obstacleSpriteNodes: [SKSpriteNode] = self["Ground"] as! [SKSpriteNode]
  lazy var polygonObstacles: [GKPolygonObstacle] = []
  let graph = GKObstacleGraph(obstacles: [], bufferRadius: 25)
  
  
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
      entityManager.add(character!)
      
      if let spriteComponent = character?.component(ofType: SpriteComponent.self) {
        spriteComponent.node.position = amberSprite.position
        spriteComponent.node.name = amberSprite.name
        amberSprite.removeFromParent()
      }
    }
    
    self["Goblin"].forEach { node in
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
    
    self["Bat"].forEach { node in
      // Создаем инстанс `Bat` entity
      let bat = Bat(entityManager: self.entityManager)
      self.entityManager.add(bat)
      
      if let spriteComponent = bat.component(ofType: SpriteComponent.self) {
        spriteComponent.node.position = node.position
        spriteComponent.node.name = node.name
        spriteComponent.node.run(SKAction(named: "bat-fly")!, withKey: "fly")
        node.removeFromParent()
      }
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
    
    guard let centerNode = connectedNode(forPoint: vector_float2(self.position)),
      let characterNode = connectedNode(forPoint: vector_float2(character!.component(ofType: SpriteComponent.self)!.node.position)) else { return }
    
    let pathNodes = graph.findPath(from: centerNode, to: characterNode) as! [GKGraphNode2D]
    
    #if DEBUG
    self.addChild(graphLayer)
    
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
  
  // MARK: - Methods
  
  /**
   Создает узел на графе поиска пути для заданной точки,
   игнорируя радиус буфера  препятствий.
   
   Возвращает `nil` если соединение не может быть установлено.
   */
  func connectedNode(forPoint point: vector_float2) -> GKGraphNode2D? {
    // Создаем узел графа для этой точки.
    let pointNode = GKGraphNode2D(point: point)
    
    // Попробуем подключить этот узел к графу.
    graph.connectUsingObstacles(node: pointNode)
    
    /*
     Проверяем, смогли ли мы подключить узел к графу.
     Если нет, это означает, что точка находится внутри буферной зоны препятствия.
     Мы не можем найти путь к точке вне графа, поэтому мы пытаемся найти ближайшую
     точку на графе и найти путь вместо этого.
     */
    if pointNode.connectedNodes.isEmpty {
      
      //TODO: Реализовать поиск ближайшей валидной точки
      
      graph.remove([pointNode])
      return nil
    }
    
    return pointNode
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
