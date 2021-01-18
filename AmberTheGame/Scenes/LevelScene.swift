import SpriteKit
import GameplayKit

class LevelScene: BaseScene {
  // MARK: - Properties
  
//  var entities = [GKEntity]()
//  var graphs = [String : GKGraph]()
  
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
    
    // Регистрируемся для получения уведомлений о том, что приложение становится неактивным.
    registerForPauseNotifications()
    
    // Регистрируемся для получения уведомлений о том, что приложение становится активным.
    registerForActiveNotifications()
    
    self.lastUpdateTimeInterval = 0
    
    // Физические контакты будет обрабатывать `LevelScene`.
    self.physicsWorld.contactDelegate = self
    
    // Инициализируем `EntityManager`.
    entityManager = EntityManager(scene: self)
    
    // Функция для поиска местоположений узлов по набору имен узлов.
    func nodePointsFromNodeNames(nodeNames: [String]) -> [CGPoint] {
      let pointsNode = childNode(withName: "/PatrolPoints")!
      return nodeNames.map {
        pointsNode[$0].first!.position
      }
    }
    
    // Создаем физическое тело для `ForegroundMap`
    if let foregroundMap = childNode(withName: "ForegroundMap") as? SKTileMapNode {
      foregroundMap.giveTileMapPhysicsBody()
      obstacleSpriteNodes += foregroundMap["Ground"] as! [SKSpriteNode]
    }
    
    if let amberSprite = childNode(withName: "Amber") as? SKSpriteNode {
      Amber.loadResources()
      Enemy.loadResources()
      let amber = Amber(camera: self.camera, scene: self)
      self.character = amber
      amber.spriteComponent.node.position = amberSprite.position
      amber.spriteComponent.node.name = amberSprite.name
      entityManager.add(amber)
      amberSprite.removeFromParent()
    }
    
    self["Skeleton"].forEach { node in
      let skeleton = Skeleton()
      skeleton.spriteComponent.node.position = node.position
      skeleton.spriteComponent.node.xScale = node.xScale
      skeleton.spriteComponent.node.name = node.name
      self.entityManager.add(skeleton)
      node.removeFromParent()
      
      if let movementComponent = skeleton.component(ofType: MovementComponent.self) {
        movementComponent.facing = MovementComponent.FacingType(rawValue: node.xScale)!
      }
      
      // Если у объекта есть `IntelligenceComponent`, входим в его начальное состояние.
      if let intelligenceComponent = skeleton.component(ofType: IntelligenceComponent.self) {
        intelligenceComponent.enterInitialState()
      }
    }
    
    self["Bat"].forEach { node in
      let patrolPoints = nodePointsFromNodeNames(nodeNames: ["bat_point01", "bat_point02", "bat_point03", "bat_point04"])
      
      let bat = Bat(patrolPoints: patrolPoints, nestPoint: node.position)
      bat.spriteComponent.node.name = node.name
      bat.spriteComponent.node.position = node.position
      self.entityManager.add(bat)
      node.removeFromParent()
      
      // Если у объекта есть `IntelligenceComponent`, входим в его начальное состояние.
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
    
    // !!!!!!!!
    for agentComponent in entityManager.getAllAgents() {
      let wait = SKAction.wait(forDuration: TimeInterval(0.0))
      let startAgent = SKAction.run({agentComponent.startAgent()})
      self.run(SKAction.sequence([wait, startAgent]))
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
  
  // MARK: - Convenience
  
  func addEntity(entity: GKEntity, spriteInScene: SKNode) {
    let entity = Skeleton()
    entity.spriteComponent.node.position = spriteInScene.position
    entity.spriteComponent.node.xScale = spriteInScene.xScale
    entity.spriteComponent.node.name = spriteInScene.name
    self.entityManager.add(entity)
    spriteInScene.removeFromParent()
    
    if let movementComponent = entity.component(ofType: MovementComponent.self) {
      movementComponent.facing = MovementComponent.FacingType(rawValue: spriteInScene.xScale)!
    }
    
    // Если у объекта есть `IntelligenceComponent`, входим в его начальное состояние.
    if let intelligenceComponent = entity.component(ofType: IntelligenceComponent.self) {
      intelligenceComponent.enterInitialState()
    }
  }
}
