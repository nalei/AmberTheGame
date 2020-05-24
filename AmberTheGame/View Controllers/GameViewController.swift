import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
    // including entities and graphs.
    if let scene = GKScene(fileNamed: "LevelScene") {
      
      // Get the SKScene from the loaded GKScene
      if let sceneNode = scene.rootNode as! LevelScene? {
        
        // Copy gameplay related content over to the scene
        sceneNode.entities = scene.entities
        sceneNode.graphs = scene.graphs
        
        // Resize the scene to better use the device aspect ratio.
        let scaleFactor = sceneNode.size.height / view.bounds.height
        
        // Set the scale mode to scale to fit the window
        sceneNode.scaleMode = .aspectFill
        sceneNode.size.width = view.bounds.width * scaleFactor
        
        // Present the scene
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
