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
    
    if let amberSprite = childNode(withName: "Amber") as? SKSpriteNode {
      // Create instance of Amber entity
      character = Amber(camera: camera!, scene: self, entityManager: entityManager) //!!!
      
      if let spriteComponent = character?.component(ofType: SpriteComponent.self) {
        spriteComponent.node.texture = amberSprite.texture
        spriteComponent.node.position = amberSprite.position
      }
      amberSprite.removeFromParent()
      entityManager.add(character!) //!!!
    }
  }
  
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


extension GameScene: SKPhysicsContactDelegate {
  //MARK: Physics
  
  func didBegin(_ contact: SKPhysicsContact) {
    let collision:UInt32 = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask)
    
    if collision == (ColliderType.PLAYER | ColliderType.GROUND) {
      if let playerControlComponent = character?.component(ofType: PlayerControlComponent.self) {
        playerControlComponent.onGround = true
      }
    }
  }
}
