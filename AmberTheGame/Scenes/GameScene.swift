import SpriteKit
import GameplayKit

class GameScene: SKScene {
  var entities = [GKEntity]()
  var graphs = [String : GKGraph]()
  
  var lastUpdateTime : TimeInterval = 0
  
  // Entity manager
  var entityManager: EntityManager!
  
  override func sceneDidLoad() {
    self.lastUpdateTime = 0
    
    // Creare instance of Entity manager
    entityManager = EntityManager(scene: self)
  }
  
  override func didMove(to view: SKView) {
    
    if let amberSprite = childNode(withName: "Amber") as? SKSpriteNode {
      
      // Creare instance of Amber GamePlayEntity
      let amber = Amber(camera: camera!, scene: self, entityManager: entityManager)
      if let spriteComponent = amber.component(ofType: SpriteComponent.self) {
        spriteComponent.node.texture = amberSprite.texture
        spriteComponent.node.position = amberSprite.position
      }
      amberSprite.removeFromParent()
      entityManager.add(amber)
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
