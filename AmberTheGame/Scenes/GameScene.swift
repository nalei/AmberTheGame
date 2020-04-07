import SpriteKit
import GameplayKit

class GameScene: SKScene {
  var entities = [GKEntity]()
  var graphs = [String : GKGraph]()
  
  // Update time
  var lastUpdateTimeInterval: TimeInterval = 0
  
  // Entity manager
  var entityManager: EntityManager!
  
  // Character
  var character: GKEntity?
  
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
        spriteComponent.node.texture = amberSprite.texture
        spriteComponent.node.position = amberSprite.position
        spriteComponent.node.name = "Amber"
        amberSprite.removeFromParent()
        
        //        let groundDetector = SKNode()
        //        groundDetector.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 36, height: 2), center: CGPoint(x: 0, y: 4))
        //        groundDetector.physicsBody?.categoryBitMask = ColliderType.GROUNDDETECTOR
        //        groundDetector.physicsBody?.collisionBitMask = ColliderType.GROUND
        //        groundDetector.physicsBody?.contactTestBitMask = ColliderType.GROUND
        //        spriteComponent.node.addChild(groundDetector)
        //
        //        let pinJoint = SKPhysicsJointFixed.joint(
        //          withBodyA: spriteComponent.node.physicsBody!,
        //          bodyB: groundDetector.physicsBody!,
        //          anchor: spriteComponent.node.position)
        //        self.physicsWorld.add(pinJoint)
      }
    }
    
    let goblin = Goblin(entityManager: entityManager)
    entityManager.add(goblin)
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
  
  // MARK: Scene Life Cycle
  
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


//MARK: Physics

extension GameScene: SKPhysicsContactDelegate {
  
  //  func didBegin(_ contact: SKPhysicsContact) {
  //    handleContact(contact: contact) { (ContactNotifiableType: ContactNotifiableType, otherEntity: GKEntity) in
  //      ContactNotifiableType.contactWithEntityDidBegin(otherEntity)
  //    }
  //  }
  //
  //  func handleContact(contact: SKPhysicsContact, contactCallback: (ContactNotifiableType, GKEntity) -> Void) {
  //    let entityA = contact.bodyA.node?.entity
  //    let entityB = contact.bodyB.node?.entity
  //
  //    /*
  //     If `entityA` is a notifiable type and `colliderTypeA` specifies that it should be notified
  //     of contact with `colliderTypeB`, call the callback on `entityA`.
  //     */
  //    if let notifiableEntity = entityA as? ContactNotifiableType, let otherEntity = entityB {
  //      print("entityA")
  //      contactCallback(notifiableEntity, otherEntity)
  //    }
  //
  //    /*
  //     If `entityB` is a notifiable type and `colliderTypeB` specifies that it should be notified
  //     of contact with `colliderTypeA`, call the callback on `entityB`.
  //     */
  //    if let notifiableEntity = entityB as? ContactNotifiableType, let otherEntity = entityA {
  //      print("entityB")
  //      contactCallback(notifiableEntity, otherEntity)
  //    }
  //  }
  
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
