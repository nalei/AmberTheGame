import SpriteKit

class HomeEndScene: BaseScene {
  // MARK: - Properties
  
  /// Кнопка "NEW GAME".
  var proceedButton: ButtonNode? {
    return self.childNode(withName: ButtonIdentifier.proceedToNextScene.rawValue) as? ButtonNode
  }
  
  /// Спрайт с именем "Сlouds".
  var clouds: SKSpriteNode? {
    return self.childNode(withName: "Сlouds") as? SKSpriteNode
  }

  /// Копия спрайта с именем  "Сlouds" (будет создана при загрузке сцены).
  var cloudsCopy: SKSpriteNode?
  
  
  // MARK: - Scene Life Cycle
  
  override func didMove(to view: SKView) {
    super.didMove(to: view)

    if let clouds = self.clouds {
      cloudsCopy = clouds.copy() as? SKSpriteNode
      cloudsCopy?.position = CGPoint(x: clouds.position.x + clouds.size.width, y: clouds.position.y)
      addChild(cloudsCopy!)
    }
    
//    if let bokehEmitter = SKEmitterNode(fileNamed: "bokeh.sks") {
//      bokehEmitter.targetNode = self
//      bokehEmitter.particleZPosition = 1
//      bokehEmitter.fieldBitMask = 1
//      bokehEmitter.name = "BokehEmitter"
//      self.addChild(bokehEmitter)
//    }
  }
  
  override func update(_ currentTime: TimeInterval) {
    if let clouds = self.clouds, let cloudsCopy = self.cloudsCopy {
      clouds.position = CGPoint(x: clouds.position.x - 0.3, y: clouds.position.y)
      cloudsCopy.position = CGPoint(x: cloudsCopy.position.x - 0.3, y: cloudsCopy.position.y)
      
      if clouds.position.x < -clouds.size.width {
        clouds.position = CGPoint(x: cloudsCopy.position.x + cloudsCopy.size.width, y: clouds.position.y)
      }

      if cloudsCopy.position.x < -cloudsCopy.size.width {
        cloudsCopy.position = CGPoint(x: clouds.position.x + clouds.size.width, y: cloudsCopy.position.y)
      }
    }
  }
}
