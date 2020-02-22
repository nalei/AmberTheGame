import SpriteKit
import GameplayKit

class GameScene: SKScene {
  var entities = [GKEntity]()
  var graphs = [String : GKGraph]()
  
  var lastUpdateTime: TimeInterval = 0
  
  // Entity manager
  var entityManager: EntityManager!
  
  // Character
  var character: GKEntity?
  
  override func sceneDidLoad() {
    self.lastUpdateTime = 0
    
    // Creare instance of Entity manager
    entityManager = EntityManager(scene: self)
  }
  
  override func didMove(to view: SKView) {
    
    self.physicsWorld.contactDelegate = self
    
    if let foregroundMap = childNode(withName: "ForegroundMap") as? SKTileMapNode {
      giveTileMapPhysicsBody(tileMap: foregroundMap)
    }
    
    if let amberSprite = childNode(withName: "Amber") as? SKSpriteNode, let camera = self.camera {
      
      // Create instance of Amber entity
      character = Amber(camera: camera, scene: self, entityManager: entityManager)
      
      if let spriteComponent = character?.component(ofType: SpriteComponent.self) {
        spriteComponent.node.texture = amberSprite.texture
        spriteComponent.node.position = amberSprite.position
      }
      amberSprite.removeFromParent()
      entityManager.add(character!) //!!!
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
  
  private func giveTileMapPhysicsBody(tileMap: SKTileMapNode) {
    let tileSize = tileMap.tileSize
    let halfWidth = CGFloat(tileMap.numberOfColumns) / 2 * tileSize.width
    let halfHeight = CGFloat(tileMap.numberOfRows) / 2 * tileSize.height
    
    for col in 0..<tileMap.numberOfColumns {
      for row in 0..<tileMap.numberOfRows {
        if let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row),
        let isGround = tileDefinition.userData?["isGround"] as? Bool {
          
          if isGround {
            let texture = tileDefinition.textures[0]
            let x = CGFloat(col) * tileSize.width - halfWidth + (tileSize.width / 2)
            let y = CGFloat(row) * tileSize.height - halfHeight + (tileSize.height / 2)
            
            let physicsBody = SKPhysicsBody(
              rectangleOf: CGSize(
                width: texture.size().width,
                height: texture.size().height
              )
            )
            physicsBody.categoryBitMask = ColliderType.GROUND
            physicsBody.contactTestBitMask = ColliderType.PLAYER
            physicsBody.affectedByGravity = false
            physicsBody.isDynamic = false
            physicsBody.allowsRotation = false
            physicsBody.friction = 0.1
            physicsBody.restitution = 0
            physicsBody.mass = 30
            
            let tileNode = SKNode()
            tileNode.position = CGPoint(x: x, y: y)
            tileNode.physicsBody = physicsBody
            
            tileMap.addChild(tileNode)
          }
        }
      }
    }
  }
  
  
  // MARK: Scene Life Cycle
  
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
    
    // Initialize _lastUpdateTime if it has not already been
    if (self.lastUpdateTime == 0) {
      self.lastUpdateTime = currentTime
    }
    
    // Calculate time since last update
    let dt = currentTime - self.lastUpdateTime
    
    // Update entities
    for entity in self.entities {
      entity.update(deltaTime: dt)
    }
    
    self.lastUpdateTime = currentTime
    
    entityManager.update(deltaTime: dt)
  }
}

//MARK: Physics

extension GameScene: SKPhysicsContactDelegate {

  func didBegin(_ contact: SKPhysicsContact) {
    let collision:UInt32 = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask)

    if collision == (ColliderType.PLAYER | ColliderType.GROUND) {
      if collisionDirection(contact) == .Bottom {
        if let movementComponent = character?.component(ofType: MovementComponent.self) {
          movementComponent.onGround = true
        }
      }
    }
  }

  private func collisionDirection(_ contact: SKPhysicsContact) -> Collision.Direction {
    if contact.contactNormal.dy > 0.2 && contact.contactNormal.dy <= 1 {
      return .Bottom
    }
    return .None
  }
}
