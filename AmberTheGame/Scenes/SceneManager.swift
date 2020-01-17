import SpriteKit

class SceneManager {
  
  //MARK: Shared Instance

  static let shared : SceneManager = {
    let instance = SceneManager(gameInput: TouchControlInputNode(frame: CGRect()))
    return instance
  }()
  
  //MARK: Local Variable
  
  var gameInput: TouchControlInputNode?
  
  //MARK: Init
  
  init(gameInput: TouchControlInputNode) {
    self.gameInput = gameInput
  }
}
