import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, SceneManagerDelegate {
  // MARK: - Properties
  
  /// Логотип, который отображается перед тем как будет загружена `HomeScene`.
  @IBOutlet var logoView: UIImageView!
  
  /// Scene manager.
  var sceneManager: SceneManager!
  
  
  // MARK: - View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let view = self.view as! SKView
    sceneManager = SceneManager(presentingView: view)
    sceneManager.delegate = self
    sceneManager.presentScene(identifier: .home)
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
  
  
  // MARK: - SceneManagerDelegate
  
  func sceneManager(_ sceneManager: SceneManager, didTransitionTo scene: GKScene) {
      // Fade out the app's initial loading `logoView` if it is visible.
      UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
          self.logoView.alpha = 0.0
      }, completion: { _ in
          self.logoView.isHidden = true
      })
  }
}
