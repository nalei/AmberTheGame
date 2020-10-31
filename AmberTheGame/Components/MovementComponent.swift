import SpriteKit
import GameplayKit

class MovementComponent : GKComponent {
  // MARK: - Properties
  
  enum FacingType: CGFloat {
    case left = -1
    case right = 1
  }
  
  var walkSpeed: CGFloat = 320 //Default value
  var maxJump: CGFloat  = 130 //Default value
  var facing: FacingType = .right
  
  var accel: CGFloat  = 40 //Default value
  var decel: CGFloat  = 80 //Default value
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
  
  /// The `PhysicsComponent` for this component's entity.
  var physicsComponent: PhysicsComponent {
    guard let physicsComponent = entity?.component(ofType: PhysicsComponent.self) else {
      fatalError("A MovementComponent's entity must have a PhysicsComponent")
    }
    return physicsComponent
  }
  
  
  // MARK: - Initializers
  
  init(walkSpeed: CGFloat, maxJump: CGFloat, accel: CGFloat, decel: CGFloat) {
    super.init()
    self.walkSpeed = walkSpeed
    self.maxJump = maxJump
    self.accel = accel
    self.decel = decel
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
      physicsComponent.physicsBody.applyImpulse(CGVector(dx: 0.0, dy: maxJump))
      if let animationComponent = entity?.component(ofType: AnimationComponent.self) {
        animationComponent.stateMachine?.enter(JumpingState.self)
      }
      onGround = false
    }
  }
  
  func stopJump() {
    jumpButtonPressed = false
  }
  
  // MARK: - GKComponent Life Cycle
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    hSpeed = physicsComponent.physicsBody.velocity.dx
    
    // Начинаем движение, если кнопка нажата
    if moveButtonPressed {
      hSpeed = approach(start: hSpeed, end: walkSpeed * facing.rawValue, shift: accel)
      physicsComponent.physicsBody.velocity.dx = hSpeed
    }
    
    // Останавливаем движение, если кнопка отпущена
    if !moveButtonPressed {
      hSpeed = approach(start: hSpeed, end: 0, shift: decel)
      physicsComponent.physicsBody.velocity.dx = hSpeed
    }
    
    // Прерываем прыжок, если кнопка отпущена
    if !jumpButtonPressed && physicsComponent.physicsBody.velocity.dy > 0 {
      physicsComponent.physicsBody.velocity.dy *= 0.5
    }
    
    // Если тело не имеет контакта с землёй, `onGround` переводим в false
    if !physicsComponent.isContactByGround() {
      onGround = false
    }
  
    // Анимация
    if let animationComponent = entity?.component(ofType: AnimationComponent.self) {
      
      if animationComponent.stateMachine?.currentState is HitState ||
          animationComponent.stateMachine?.currentState is DamageState {
        
        // Не меняем состояние если объект находится в `HitState` или `DamageState`

      } else {
        if onGround {
          if moveButtonPressed {
            animationComponent.stateMachine?.enter(WalkingState.self)
          } else {
            animationComponent.stateMachine?.enter(IdleState.self)
          }
        } else if physicsComponent.physicsBody.velocity.dy < -100 {
          animationComponent.stateMachine?.enter(FallingState.self)
        }
      }
    }
    
    // Восстанавливаем размеры спрайта
    spriteComponent.node.xScale = approach(start: spriteComponent.node.xScale, end: facing.rawValue, shift: 0.04)
    spriteComponent.node.yScale = approach(start: spriteComponent.node.yScale, end: 1, shift: 0.04)
  }
  
  // MARK: - Convenience
  
  private func approach(start: CGFloat, end: CGFloat, shift: CGFloat) -> CGFloat {
    return start < end
      ? min(start + shift, end)
      : max(start - shift, end)
  }
}
