import SpriteKit
import GameplayKit

class MovementComponent : GKComponent {
  enum FacingType: CGFloat {
    case left = -1
    case right = 1
  }
  
  let walkSpeed: CGFloat = 320
  let maxJump: CGFloat  = 150
  var facing: FacingType = .right
  
  var accel: CGFloat  = 40
  var decel: CGFloat  = 30
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
    spriteComponent.node.xScale = facing.rawValue
    
  }
  
  func stopMoving() {
    moveButtonPressed = false
  }
  
  func jump() {
    jumpButtonPressed = true
    
    if onGround {
      spriteComponent.node.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: maxJump))
      if let animationComponent = entity?.component(ofType: AnimationComponent.self) {
        if (animationComponent.stateMachine?.canEnterState(JumpingState.self))! {
          animationComponent.stateMachine?.enter(JumpingState.self)
        }
      }
      onGround = false
    }
  }
  
  func stopJump() {
    jumpButtonPressed = false
  }
  
  // MARK: GKComponent Life Cycle
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    let spriteNode = spriteComponent.node
    
    // Начинаем движение, если кнопка нажата
    if moveButtonPressed {
      hSpeed = approach(start: hSpeed, end: walkSpeed * facing.rawValue, shift: accel)
      //spriteNode.position.x = spriteNode.position.x + hSpeed
      spriteNode.physicsBody?.velocity.dx = hSpeed
    }
    
    // Останавливаем движение, если кнопка отпущена
    if !moveButtonPressed && hSpeed != 0 {
      hSpeed = approach(start: hSpeed, end: 0, shift: decel)
      //spriteNode.position.x = spriteNode.position.x + hSpeed
      spriteNode.physicsBody?.velocity.dx = hSpeed
    }
    
    // Прерываем прыжок, если кнопка отпущена
    if !jumpButtonPressed && (spriteNode.physicsBody?.velocity.dy)! > 0 {
      spriteNode.physicsBody?.velocity.dy *= 0.5
    }
    
    // Если тело движется вниз и не имеет контакта с землёй
    if (spriteNode.physicsBody?.velocity.dy)! < -100 && !spriteComponent.isContactByGround() {
      if let animationComponent = entity?.component(ofType: AnimationComponent.self) {
        if (animationComponent.stateMachine?.canEnterState(FallingState.self))! {
          animationComponent.stateMachine?.enter(FallingState.self)
        }
      }
      onGround = false
    }
    
    // Анимация
    if let animationComponent = entity?.component(ofType: AnimationComponent.self) {
      if onGround {
        if hSpeed == 0 || !moveButtonPressed {
          if (animationComponent.stateMachine?.canEnterState(IdleState.self))! {
            animationComponent.stateMachine?.enter(IdleState.self)
          }
        } else {
          if (animationComponent.stateMachine?.canEnterState(WalkingState.self))! {
            animationComponent.stateMachine?.enter(WalkingState.self)
          }
        }
      }
    }
    
    // Восстанавливаем размеры спрайта
    spriteNode.xScale = approach(start: spriteNode.xScale, end: facing.rawValue, shift: 0.04)
    spriteNode.yScale = approach(start: spriteNode.yScale, end: 1, shift: 0.04)
  }
  
  // MARK: Helper
  
  private func approach(start: CGFloat, end: CGFloat, shift: CGFloat) -> CGFloat {
    return start < end
      ? min(start + shift, end)
      : max(start - shift, end)
  }
}
