import SpriteKit
import GameplayKit

class GameScene: SKScene, ControlInputSourceDelegate {
  var entities = [GKEntity]()
  var graphs = [String : GKGraph]()
  
  private var lastUpdateTime : TimeInterval = 0
  
  // Player Control
  var touchControlNode: TouchControlInputNode?
  
  func follow(command: String?) {
    print(command!)
  }
  
  override func sceneDidLoad() {
    self.lastUpdateTime = 0
    
    // Add Player Control
    touchControlNode = TouchControlInputNode(frame: self.frame)
    touchControlNode?.inputDelegate = self
    addChild(touchControlNode!)
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
  }
}
