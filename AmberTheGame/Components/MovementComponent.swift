import SpriteKit
import GameplayKit

enum FacingType: CGFloat {
  case left = -1
  case right = 1
}

class MovementComponent : GKComponent {
  // MARK: Properties
  
  let walkSpeed: CGFloat = 250
  let maxJump: CGFloat  = 60
  
  var accel: CGFloat  = 40
  var decel: CGFloat  = 40
  var hSpeed: CGFloat = 0
  var facing: FacingType = .right
  
  var isMoving: Bool  = false
  var isJumping: Bool = false
  var onGround: Bool  = false
  
  /// The `SpriteComponent` for this component's entity.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
      fatalError("A MovementComponent's entity must have a SpriteComponent")
    }
    return spriteComponent
  }
  
  // MARK: Initialization
  
  override init() {
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func moveTo(_ facing: FacingType) {
    self.facing = facing
    isMoving = true
  }
  
  func stopMoving() {
    isMoving = false
  }
  
  func jump() {
    let spriteNode = spriteComponent.node
    if onGround {
      spriteNode.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: maxJump))
      onGround = false
      isJumping = true
    }
  }
  
  func stopJump() {
    isJumping = false
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    let spriteNode = spriteComponent.node
    
    if isMoving && hSpeed != walkSpeed {
      hSpeed = approach(start: hSpeed, end: walkSpeed * facing.rawValue, shift: accel)
      spriteNode.physicsBody?.velocity.dx = hSpeed
    } else if  hSpeed != 0 {
      hSpeed = approach(start: hSpeed, end: 0, shift: decel)
      spriteNode.physicsBody?.velocity.dx = hSpeed
    }

    // Прерываем прыжок, если кнопка отпущена
    if !isJumping && (spriteNode.physicsBody?.velocity.dy)! > 0 {
      spriteNode.physicsBody?.velocity.dy *= 0.5
    }
    
    spriteNode.xScale = facing.rawValue
  }
  
  // MARK: Helper
  
  func approach(start: CGFloat, end: CGFloat, shift: CGFloat) -> CGFloat {
    return start < end
      ? min(start + shift, end)
      : max(start - shift, end)
  }
}
