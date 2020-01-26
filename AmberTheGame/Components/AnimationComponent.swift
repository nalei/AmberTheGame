import SpriteKit
import GameplayKit

class AnimationComponent: GKComponent {
  var stateMachine: GKStateMachine!
  
  /// The `SpriteComponent` for this component's entity.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
      fatalError("A MovementComponent's entity must have a SpriteComponent")
    }
    return spriteComponent
  }
  
  override init() {
    super.init()
    
    stateMachine = GKStateMachine(states: [
      IdleState(animationComponent: self),
      WalkingState(animationComponent: self)
    ])
    
    stateMachine.enter(WalkingState.self)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
