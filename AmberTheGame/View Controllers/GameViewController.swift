import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let scene = GKScene(fileNamed: "LevelScene") {
      
      if let sceneNode = scene.rootNode as! LevelScene? {
        
        sceneNode.entities = scene.entities
        sceneNode.graphs = scene.graphs
        
        let scaleFactor = sceneNode.size.height / view.bounds.height
        sceneNode.size.width = view.bounds.width * scaleFactor
        
        sceneNode.scaleMode = .aspectFit
        
        if let view = self.view as! SKView? {
          view.presentScene(sceneNode)
          
          view.ignoresSiblingOrder = true
        }
      }
    }
  }
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return .allButUpsideDown
    } else {
      return .all
    }
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
}
