import SpriteKit

class HomeEndScene: BaseScene {
  // MARK: - Properties
  
  /// Кнопка "NEW GAME".
  var proceedButton: ButtonNode? {
    return self.childNode(withName: ButtonIdentifier.proceedToNextScene.rawValue) as? ButtonNode
  }
}
