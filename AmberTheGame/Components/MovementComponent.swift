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
  
  var moveButtonPressed: Bool = false
  var jumpButtonPressed: Bool = false
  var onGround: Bool = false
  
  /// The `SpriteComponent` for this component's entity.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
      fatalError("A MovementComponent's entity must have a SpriteComponent")
    }
    return spriteComponent
  }
  
  /// The `AnimationComponent` for this component's entity.
  var animationComponent: AnimationComponent {
    guard let animationComponent = entity?.component(ofType: AnimationComponent.self) else {
      fatalError("A MovementComponent's entity must have a AnimationComponent")
    }
    return animationComponent
  }
  
  // MARK: Initialization
  
  override init() {
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func moveTo(_ facing: FacingType) {
    moveButtonPressed = true
    self.facing = facing
    
    let stateMachine = animationComponent.stateMachine
    if (stateMachine?.canEnterState(WalkingState.self))! {
        stateMachine?.enter(WalkingState.self)
    }
  }
  
  func stopMoving() {
    moveButtonPressed = false
  }
  
  func jump() {
    jumpButtonPressed = true
    let spriteNode = spriteComponent.node
    
    if onGround {
      spriteNode.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: maxJump))
      onGround = false
    }
  }
  
  func stopJump() {
    jumpButtonPressed = false
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    let spriteNode = spriteComponent.node
    
    if moveButtonPressed && hSpeed != walkSpeed {
      hSpeed = approach(start: hSpeed, end: walkSpeed * facing.rawValue, shift: accel)
      spriteNode.physicsBody?.velocity.dx = hSpeed
    }
    
    if !moveButtonPressed && hSpeed != 0 {
      hSpeed = approach(start: hSpeed, end: 0, shift: decel)
      spriteNode.physicsBody?.velocity.dx = hSpeed
    }

    // Прерываем прыжок, если кнопка отпущена
    if !jumpButtonPressed && (spriteNode.physicsBody?.velocity.dy)! > 0 {
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
