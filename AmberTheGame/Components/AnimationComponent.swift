import SpriteKit
import GameplayKit

class AnimationComponent: GKComponent {
  var stateMachine: GKStateMachine! //!!!
  
  override init() {
    super.init()
    
    stateMachine = GKStateMachine(states: [
      IdleState(animationComponent: self),
      WalkingState(animationComponent: self)
    ])
    
    stateMachine.enter(IdleState.self)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
