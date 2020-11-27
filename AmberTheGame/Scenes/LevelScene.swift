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
      if let movementComponent = skeleton.component(ofType: MovementComponent.self) {
        movementComponent.facing = MovementComponent.FacingType(rawValue: node.xScale)!
      }
      skeleton.spriteComponent.node.name = node.name
      self.entityManager.add(skeleton)
      node.removeFromParent()
      
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
    handleContact(contact: contact) { (ContactNotifiableType: ContactNotifiableType, otherEntity: GKEntity) in
      ContactNotifiableType.contactWithEntityDidBegin(otherEntity)
    }
    
    if contact.bodyA.categoryBitMask == ColliderType.GROUND.rawValue || contact.bodyB.categoryBitMask == ColliderType.GROUND.rawValue {
      if collisionDirection(contact) == .bottom {
        if let movementComponent = contact.bodyA.node?.entity?.component(ofType: MovementComponent.self) {
          movementComponent.onGround = true
        } else if let movementComponent = contact.bodyB.node?.entity?.component(ofType: MovementComponent.self) {
          movementComponent.onGround = true
        }
      }
    }
  }
  
  func didEnd(_ contact: SKPhysicsContact) {
    handleContact(contact: contact) { (ContactNotifiableType: ContactNotifiableType, otherEntity: GKEntity) in
      ContactNotifiableType.contactWithEntityDidEnd(otherEntity)
    }
  }
  
  private func handleContact(contact: SKPhysicsContact, contactCallback: (ContactNotifiableType, GKEntity) -> Void) {
    // Получаем `ColliderType` для каждого тела, которое учавствует в столкновении.
    let colliderTypeA = ColliderType(rawValue: contact.bodyA.categoryBitMask)
    let colliderTypeB = ColliderType(rawValue: contact.bodyB.categoryBitMask)
    
    // Определяем, какой `ColliderType` должен быть уведомлен о контакте.
    let aWantsCallback = colliderTypeA.notifyOnContactWith(colliderTypeB)
    let bWantsCallback = colliderTypeB.notifyOnContactWith(colliderTypeA)
    
    
    // Убеждаемся, что хотя бы одна из сущностей хочет обработать этот контакт.
    // assert(aWantsCallback || bWantsCallback, "Unhandled physics contact - A = \(colliderTypeA), B = \(colliderTypeB)")
    
    let entityA = contact.bodyA.node?.entity
    let entityB = contact.bodyB.node?.entity
    
    /*
     Если `entityA` является уведомляемым типом, а `colliderTypeA` указывает, что он должен быть уведомлен
     о контакте с `colliderTypeB`, вызываем колбэк `entityA`.
     */
    if let notifiableEntity = entityA as? ContactNotifiableType, let otherEntity = entityB, aWantsCallback {
      contactCallback(notifiableEntity, otherEntity)
    }
    
    /*
     Если `entityB` является уведомляемым типом, а `scolliderTypeB` указывает, что он должен быть уведомлен
     о контакте с `colliderTypeA`, вызываем колбэк `entityB`.
     */
    if let notifiableEntity = entityB as? ContactNotifiableType, let otherEntity = entityA, bWantsCallback {
      contactCallback(notifiableEntity, otherEntity)
    }
  }
  
  private func collisionDirection(_ contact: SKPhysicsContact) -> ColliderType.Direction {
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
