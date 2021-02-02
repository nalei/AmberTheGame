import SpriteKit
import GameplayKit

class SpriteComponent: GKComponent {
  // MARK: - Properties
  
  let node: SKSpriteNode
  
  
  // MARK: - Initializers
  
  init(texture: SKTexture, size: CGSize) {
    node = SKSpriteNode(texture: texture, color: .white, size: size)
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - GKComponent Life Cycle
  
  override func didAddToEntity() {
    node.entity = entity
  }

  override func willRemoveFromEntity() {
    node.entity = nil
  }
  
  
  // MARK: - Actions
  
  public func squashAndSretch(xScale: CGFloat, yScale: CGFloat) {
    node.xScale = xScale * node.xScale
    node.yScale = yScale
  }
  
  public func bounceBack(force: CGFloat) {
    node.physicsBody?.applyImpulse(CGVector(dx: (-node.xScale * force), dy: 0.0))
  }
  
  /// Создаем, запускаем и удаляем эмиттер частиц для прыжка.
  public func launchJumpParticleEffect() {
    if let levelScene = node.scene as? LevelScene, let jumpEmitter = SKEmitterNode(fileNamed: "jump.sks") {
      jumpEmitter.targetNode = levelScene
      jumpEmitter.particleZPosition = -1
      jumpEmitter.position = CGPoint(x: 0, y: 29)
      node.addChild(jumpEmitter)
      
      let emitterDuration = Double(jumpEmitter.numParticlesToEmit) / Double(jumpEmitter.particleBirthRate) + Double(jumpEmitter.particleLifetime + jumpEmitter.particleLifetimeRange/2)
      let wait = SKAction.wait(forDuration: TimeInterval(emitterDuration))
      let remove = SKAction.removeFromParent()
      jumpEmitter.run(SKAction.sequence([wait, remove]))
    }
  }
  
  /// Анимация: меняет цвет спрайта на белый, в течение 0.15c.
  public func pulsedWhite() {
    let add = SKAction.run({self.node.shader = Amber.blinckShader!})
    let wait = SKAction.wait(forDuration: 0.15)
    let remove = SKAction.run({self.node.shader = nil})
    
    self.node.run(SKAction.sequence([add, wait, remove]))
  }
}

extension SKSpriteNode {
  func drawBorder(color: UIColor, width: CGFloat) {
    let shapeNode = SKShapeNode(rect: frame)
    shapeNode.fillColor = .clear
    shapeNode.strokeColor = color
    shapeNode.lineWidth = width
    addChild(shapeNode)
  }
}
