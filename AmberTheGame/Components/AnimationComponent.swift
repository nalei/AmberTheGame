import SpriteKit
import GameplayKit

class AnimationComponent: GKComponent {
  /**
    The state machine for this `AnimationComponent`. Defined as an implicitly
    unwrapped optional property, because it is created during initialization,
    but cannot be created until after we have called super.init().
  */
  var stateMachine: GKStateMachine!
  
  var idle: SKTexture?
  var run: SKAction?
  var jumpUp: SKTexture?
  var jumpMiddle: SKTexture?
  var jumpDown: SKTexture?
  
  init(idle: SKTexture?, run: SKAction?, jumpUp: SKTexture?, jumpMiddle: SKTexture?, jumpDown: SKTexture?) {
    super.init()
    
    self.idle = idle
    self.run = run
    self.jumpUp = jumpUp ?? idle
    self.jumpMiddle = jumpMiddle ?? jumpUp ?? idle
    self.jumpDown = jumpDown ?? jumpMiddle ?? jumpUp ?? idle
    
    stateMachine = GKStateMachine(states: [
      IdleState(animationComponent: self),
      WalkingState(animationComponent: self),
      JumpingState(animationComponent: self),
      FallingState(animationComponent: self)
    ])
    
    stateMachine.enter(IdleState.self)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    stateMachine.update(deltaTime: seconds)
  }
}
