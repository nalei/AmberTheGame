import SpriteKit
import GameplayKit

protocol SceneManagerDelegate: class {
  // Вызывается всякий раз, когда менеджер сцен переходит к новой сцене.
  func sceneManager(_ sceneManager: SceneManager, didTransitionTo scene: GKScene)
}

/// Менеджер  управления  сценами `BaseScene`.
final class SceneManager {
  // MARK: - Types
  
  enum SceneIdentifier: String {
    case home = "HomeScene"
    case level = "LevelScene"
    case end = "EndScene"
    
    func getName() -> String {
      return self.rawValue
    }
  }
  
  
  // MARK: - Properties
  
  /// `SKView` Который будет использоваться для отображения игровых сцен.
  let presentingView: SKView
  
  /// Делегат для `SceneManager`.
  weak var delegate: SceneManagerDelegate?
  
  
  // MARK: - Initialization
  
  init(presentingView: SKView) {
    self.presentingView = presentingView
  }
  
  
  // MARK: - Scene Presentation
  
  /// Настраивает и отображает сцену на устройстве.
  func presentScene(identifier sceneIdentifier: SceneIdentifier) {
    
    let sceneName = sceneIdentifier.getName()
    
    if let scene = GKScene(fileNamed: sceneName) {
      if let sceneNode = scene.rootNode as! BaseScene? {
        
        let scaleFactor = sceneNode.size.height / presentingView.bounds.height
        sceneNode.size.width = presentingView.bounds.width * scaleFactor
        sceneNode.scaleMode = .aspectFit
        
        // Отображаем сцену на устройстве.
        let transition = SKTransition.fade(withDuration: GameplayConfiguration.SceneManager.transitionDuration)
        presentingView.presentScene(sceneNode, transition: transition)
        
        // Предоставляем загружаемой сцене ссылку на `SceneManger`.
        sceneNode.sceneManager = self
        
        // Сообщаем делегату, что менеджер отобразил сцену.
        self.delegate?.sceneManager(self, didTransitionTo: scene)
      }
    }
  }
}
