import SpriteKit
import GameplayKit

class AnimationComponent: GKComponent {
  // MARK: - Properties

  var stateMachine: GKStateMachine!
  
  var idle: SKTexture?
  var run: SKAction?
  var jumpUp: SKTexture?
  var jumpMiddle: SKTexture?
  var jumpDown: SKTexture?
  var hit: SKAction?
  var damage: SKAction?
  
  
  // MARK: - Initializers
  
  init(idle: SKTexture?, run: SKAction?, jumpUp: SKTexture?, jumpMiddle: SKTexture?, jumpDown: SKTexture?, hit: SKAction?, damage: SKAction?) {
    super.init()
    
    self.idle = idle
    self.run = run
    self.jumpUp = jumpUp ?? idle
    self.jumpMiddle = jumpMiddle ?? jumpUp ?? idle
    self.jumpDown = jumpDown ?? jumpMiddle ?? jumpUp ?? idle
    self.hit = hit
    self.damage = damage
    
    stateMachine = GKStateMachine(states: [
      IdleState(animationComponent: self),
      WalkingState(animationComponent: self),
      JumpingState(animationComponent: self),
      FallingState(animationComponent: self),
      HitState(animationComponent: self),
      DamageState(animationComponent: self)
    ])
    
    // При инициализации не входим ни в какое состояние, объект сам войдет в нужное состояние в момент начала игры
    //stateMachine.enter(IdleState.self)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - GKComponent Life Cycle
  
  override func update(deltaTime seconds: TimeInterval) {
    stateMachine.update(deltaTime: seconds)
  }
}
