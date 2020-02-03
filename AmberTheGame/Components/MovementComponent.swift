import SpriteKit
import GameplayKit

class MovementComponent : GKComponent {
  enum FacingType: CGFloat {
    case left = -1
    case right = 1
  }
  
  let walkSpeed: CGFloat = 350
  let maxJump: CGFloat  = 150
  var facing: FacingType = .right
  
  var accel: CGFloat  = 40
  var decel: CGFloat  = 40
  var hSpeed: CGFloat = 0
  
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
  
  override init() {
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func moveTo(_ facing: FacingType) {
    moveButtonPressed = true
    self.facing = facing
  }
  
  func stopMoving() {
    moveButtonPressed = false
  }
  
  func jump() {
    jumpButtonPressed = true
    
    if onGround {
      spriteComponent.node.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: maxJump))
      onGround = false
      
      if let animationComponent = entity?.component(ofType: AnimationComponent.self) {
        if (animationComponent.stateMachine?.canEnterState(JumpingState.self))! {
          animationComponent.stateMachine?.enter(JumpingState.self)
        }
      }
    }
  }
  
  func stopJump() {
    jumpButtonPressed = false
  }
  
  // MARK: GKComponent Life Cycle
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    let spriteNode = spriteComponent.node
    
    // Начинаем движение, если кнопка отпущена
    if moveButtonPressed && hSpeed != walkSpeed {
      hSpeed = approach(start: hSpeed, end: walkSpeed * facing.rawValue, shift: accel)
      spriteNode.physicsBody?.velocity.dx = hSpeed
    }
    
    // Останавливаем движение, если кнопка отпущена
    if !moveButtonPressed && hSpeed != 0 {
      hSpeed = approach(start: hSpeed, end: 0, shift: decel)
      spriteNode.physicsBody?.velocity.dx = hSpeed
    }
    
    // Прерываем прыжок, если кнопка отпущена
    if !jumpButtonPressed && (spriteNode.physicsBody?.velocity.dy)! > 0 {
      spriteNode.physicsBody?.velocity.dy *= 0.5
    }
    
    if hSpeed > 0 {
      spriteNode.xScale = 1
    } else if hSpeed < 0 {
      spriteNode.xScale = -1
    }
    
    if onGround {
      if hSpeed == 0 || !moveButtonPressed {
        if let animationComponent = entity?.component(ofType: AnimationComponent.self) {
          if (animationComponent.stateMachine?.canEnterState(IdleState.self))! {
            animationComponent.stateMachine?.enter(IdleState.self)
          }
        }
      } else {
        if let animationComponent = entity?.component(ofType: AnimationComponent.self) {
          if (animationComponent.stateMachine?.canEnterState(WalkingState.self))! {
            animationComponent.stateMachine?.enter(WalkingState.self)
          }
        }
      }
    }
    
    // Восстанавливаем размеры спрайта
    spriteNode.xScale = approach(start: spriteNode.xScale, end: facing.rawValue, shift: 0.05)
    spriteNode.yScale = approach(start: spriteNode.yScale, end: 1, shift: 0.05)
  }
  
  // MARK: Helper
  
  private func approach(start: CGFloat, end: CGFloat, shift: CGFloat) -> CGFloat {
    return start < end
      ? min(start + shift, end)
      : max(start - shift, end)
  }
}
