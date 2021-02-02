import SpriteKit

class HomeEndScene: BaseScene {
  // MARK: - Properties
  
  /// Кнопка "NEW GAME".
  var proceedButton: ButtonNode? {
    return self.childNode(withName: ButtonIdentifier.proceedToNextScene.rawValue) as? ButtonNode
  }
  
  
  // MARK: - Scene Life Cycle
  
//  override func didMove(to view: SKView) {
//    super.didMove(to: view)
//    
//    if let bokehEmitter = SKEmitterNode(fileNamed: "bokeh.sks") {
//      bokehEmitter.targetNode = self
//      bokehEmitter.particleZPosition = 1
//      bokehEmitter.fieldBitMask = 1
//      bokehEmitter.name = "BokehEmitter"
//      self.addChild(bokehEmitter)
//    }
//  }
}
