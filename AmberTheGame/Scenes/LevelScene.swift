import SpriteKit
import GameplayKit

class LevelScene: SKScene {
  // MARK: - Properties
  
  var entities = [GKEntity]()
  var graphs = [String : GKGraph]()
  
  /// Игровой персонаж, везде далее `Amber`.
  var character: Amber?
  
  /// Время, прошедшее с момента последнего обновления.
  var lastUpdateTimeInterval: TimeInterval = 0
  
  /// Entity manager
  var entityManager: EntityManager!
  
  // MARK: Pathfinding
  
  lazy var obstacleSpriteNodes: [SKSpriteNode] = self["Ground"] as! [SKSpriteNode]
  lazy var polygonObstacles: [GKPolygonObstacle] = []
  let graph = GKObstacleGraph(obstacles: [], bufferRadius: GameplayConfiguration.Enemy.pathfindingGraphBufferRadius)
  
  // MARK: Pathfinding Debug
  
  var debugDrawingEnabled = false {
    didSet {
      debugDrawingEnabledDidChange()
    }
  }
  
  var graphLayer = SKNode()
  
  
  // MARK: - Initializers
  
  deinit {
    unregisterForPauseNotifications()
    unregisterForActiveNotifications()
  }
  
  
  // MARK: - Scene Life Cycle
  
  override func didMove(to view: SKView) {
    super.didMove(to: view)
    
    registerForPauseNotifications()
    
    registerForActiveNotifications()
    
    self.lastUpdateTimeInterval = 0
    
    self.physicsWorld.contactDelegate = self
    
    entityManager = EntityManager(scene: self)
    
    // Создаем физическое тело для `ForegroundMap`
    if let foregroundMap = childNode(withName: "ForegroundMap") as? SKTileMapNode {
      foregroundMap.giveTileMapPhysicsBody()
      obstacleSpriteNodes += foregroundMap["Ground"] as! [SKSpriteNode]
    }
    
    // Функция для поиска местоположений узлов по набору имен узлов.
    func nodePointsFromNodeNames(nodeNames: [String]) -> [CGPoint] {
      let pointsNode = childNode(withName: "/PatrolPoints")!
      return nodeNames.map {
        pointsNode[$0].first!.position
      }
    }
    
    if let amberSprite = childNode(withName: "Amber") as? SKSpriteNode {
      
      let amber = Amber(camera: self.camera, scene: self)
      self.character = amber
      amber.spriteComponent.node.position = amberSprite.position
      amber.spriteComponent.node.name = amberSprite.name
      entityManager.add(amber)
      amberSprite.removeFromParent()
    }
    
    self["Goblin"].forEach { node in
      let goblin = Goblin()
      goblin.spriteComponent.node.position = node.position
      goblin.spriteComponent.node.xScale = node.xScale
      goblin.spriteComponent.node.name = node.name
      self.entityManager.add(goblin)
      node.removeFromParent()
    }
    
    self["Skeleton"].forEach { node in
      let skeleton = Skeleton()
      skeleton.spriteComponent.node.position = node.position
      skeleton.spriteComponent.node.xScale = node.xScale
      if let movementComponent = skeleton.component(ofType: MovementComponent.self) {
        movementComponent.facing = MovementComponent.FacingType(rawValue: node.xScale)!
      }
      skeleton.spriteComponent.node.name = node.name
      self.entityManager.add(skeleton)
      node.removeFromParent()
    }
    
    self["Bat"].forEach { node in
      let patrolPoints = nodePointsFromNodeNames(nodeNames: ["bat_point01", "bat_point02", "bat_point03", "bat_point04"])
      
      let bat = Bat(patrolPoints: patrolPoints, nestPoint: node.position)
      bat.spriteComponent.node.name = node.name
      bat.spriteComponent.node.position = node.position
      self.entityManager.add(bat)
      node.removeFromParent()
      
      // If the entity has an `IntelligenceComponent`, enter its initial state.
      if let intelligenceComponent = bat.component(ofType: IntelligenceComponent.self) {
        intelligenceComponent.enterInitialState()
      }
    }
    
    self["ParallaxBg"].forEach { node in
      if let parralaxBgSprite = node as? SKSpriteNode {
        let parralaxBg = ParallaxBg(spriteNode: parralaxBgSprite, camera: self.camera)
        self.entityManager.add(parralaxBg)
      }
    }
    
    if let bokehEmitter = SKEmitterNode(fileNamed: "bokeh.sks") {
      bokehEmitter.targetNode = self
      bokehEmitter.particleZPosition = 1
      bokehEmitter.fieldBitMask = 1
      bokehEmitter.name = "BokehEmitter"
      self.camera!.addChild(bokehEmitter)
    }
    
    // Добавляем препятствия в граф поиска пути
    polygonObstacles += SKNode.obstacles(fromNodeBounds: obstacleSpriteNodes)
    graph.addObstacles(polygonObstacles)
    
    #if DEBUG
    self.addChild(graphLayer)
    graphLayer.zPosition = 1
    
    debugDrawingEnabled = false
    
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
    
    // Инициализируем `lastUpdateTime`, если ешё не был инициализирован.
    if (self.lastUpdateTimeInterval == 0) {
      self.lastUpdateTimeInterval = currentTime
    }
    
    // Рассчитываем время с момента последнего обновления.
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
