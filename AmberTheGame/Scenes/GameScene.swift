import SpriteKit
import GameplayKit

class GameScene: SKScene, ControlInputSourceDelegate {
  var entities = [GKEntity]()
  var graphs = [String : GKGraph]()
  
  private var lastUpdateTime : TimeInterval = 0
  let label = SKLabelNode(fontNamed: "Courier-Bold")
  
  // Player Control
  var touchControlInputNode: TouchControlInputNode?
  
  func follow(command: String?) {
    label.text = "\(command!)"
  }
  
  override func sceneDidLoad() {
    self.lastUpdateTime = 0
    
    // Test label
    label.text = ""
    label.fontSize = 100
    label.fontColor = .white
    label.zPosition = 1
    label.verticalAlignmentMode = .center
    addChild(label)
    
    // Add Player Control
    touchControlInputNode = TouchControlInputNode(frame: self.frame)
    touchControlInputNode?.inputDelegate = self
    addChild(touchControlInputNode!)
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
