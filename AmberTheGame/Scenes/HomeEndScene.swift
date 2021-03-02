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
  
  /// Спрайт с именем "Sea".
  var sea: SKSpriteNode? {
    return self.childNode(withName: "Sea") as? SKSpriteNode
  }
  
  /// Копия спрайта с именем  "Sea" (будет создана при загрузке сцены).
  var seaCopy: SKSpriteNode?
  
  
  // MARK: - Scene Life Cycle
  
  override func didMove(to view: SKView) {
    super.didMove(to: view)

    if let clouds = self.clouds {
      cloudsCopy = clouds.copy() as? SKSpriteNode
      cloudsCopy?.position = CGPoint(x: clouds.position.x + clouds.size.width, y: clouds.position.y)
      addChild(cloudsCopy!)
    }
    
    if let sea = self.sea {
      seaCopy = sea.copy() as? SKSpriteNode
      seaCopy?.position = CGPoint(x: sea.position.x + sea.size.width, y: sea.position.y)
      addChild(seaCopy!)
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
      moveBackgroundInfinit(sprite: clouds, spriteCopy: cloudsCopy, speed: 0.3)
    }
    
    if let sea = self.sea, let seaCopy = self.seaCopy {
      moveBackgroundInfinit(sprite: sea, spriteCopy: seaCopy, speed: 0.5)
    }
  }
  
  
  // MARK: - Convenience
  
  func moveBackgroundInfinit(sprite: SKSpriteNode, spriteCopy: SKSpriteNode, speed: CGFloat) {
    sprite.position = CGPoint(x: sprite.position.x - speed, y: sprite.position.y)
    spriteCopy.position = CGPoint(x: spriteCopy.position.x - speed, y: spriteCopy.position.y)
    
    if sprite.position.x < -sprite.size.width {
      sprite.position = CGPoint(x: spriteCopy.position.x + spriteCopy.size.width, y: sprite.position.y)
    }

    if spriteCopy.position.x < -spriteCopy.size.width {
      spriteCopy.position = CGPoint(x: sprite.position.x + sprite.size.width, y: spriteCopy.position.y)
    }
  }
}
