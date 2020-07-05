import GameplayKit
import SpriteKit

class FallingState : GKState {
  unowned var animationComponent: AnimationComponent
  
  required init(animationComponent: AnimationComponent) {
    self.animationComponent = animationComponent
  }
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    guard let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) else { return }
    
    spriteComponent.node.removeAllActions()
    spriteComponent.node.texture = animationComponent.jumpMiddle
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    guard let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) else { return }

    if (spriteComponent.node.physicsBody?.velocity.dy)! < -400 {
      
      spriteComponent.node.removeAllActions()
      spriteComponent.node.texture = animationComponent.jumpDown
    }
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is IdleState.Type, is WalkingState.Type, is JumpingState.Type, is HitState.Type, is DamageState.Type:
      return true
    case is FallingState.Type:
      return false
    default:
      return false
    }
  }
}
