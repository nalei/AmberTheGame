import SpriteKit
import GameplayKit

class AnimationComponent: GKComponent {
  /**
      The state machine for this `AnimationComponent`. Defined as an implicitly
      unwrapped optional property, because it is created during initialization,
      but cannot be created until after we have called super.init().
  */
  var stateMachine: GKStateMachine!
  
  override init() {
    super.init()
    
    stateMachine = GKStateMachine(states: [
      IdleState(animationComponent: self),
      WalkingState(animationComponent: self),
      JumpingState(animationComponent: self)
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
