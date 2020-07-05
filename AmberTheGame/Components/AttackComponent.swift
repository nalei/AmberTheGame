import SpriteKit
import GameplayKit

class AttackComponent: GKComponent {
  let hitBox: SKShapeNode
  let hurtBox: SKShapeNode
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
      fatalError("A AttackComponent's entity must have a SpriteComponent")
    }
    return spriteComponent
  }
  
  /// Используется для фигур, представляющих  hitBox для отладочной отрисовки.
  var debugNode = SKNode()
  
  init(hitBoxSize: CGSize, hurtBoxSize: CGSize) {
    self.hitBox = SKShapeNode(rectOf: hitBoxSize)
    self.hurtBox = SKShapeNode(rectOf: hurtBoxSize)
    
    super.init()
    
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    // Use RGB component accessor common between `UIColor` and `NSColor`.
    SKColor.red.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    hitBox.strokeColor = SKColor(red: red, green: green, blue: blue, alpha: 0.9)
    hitBox.fillColor = SKColor(red: red, green: green, blue: blue, alpha: 0.5)
    
    // Use RGB component accessor common between `UIColor` and `NSColor`.
    SKColor.green.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    hurtBox.strokeColor = SKColor(red: red, green: green, blue: blue, alpha: 0.4)
    hurtBox.fillColor = SKColor(red: red, green: green, blue: blue, alpha: 0.2)
    
    hitBox.zPosition = 1
    hurtBox.zPosition = 1
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func hit() {
    if let animationComponent = entity?.component(ofType: AnimationComponent.self) {
      animationComponent.stateMachine?.enter(HitState.self)
    }
  }
}
