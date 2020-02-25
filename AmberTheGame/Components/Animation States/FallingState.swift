import GameplayKit
import SpriteKit

class FallingState : GKState {
  unowned var animationComponent: AnimationComponent
  
  required init(animationComponent: AnimationComponent) {
    self.animationComponent = animationComponent
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is IdleState.Type:
      return true
    case is WalkingState.Type:
      return true
    case is JumpingState.Type:
      return true
    case is FallingState.Type:
      return false
    default:
      return false
    }
  }
  
  override func didEnter(from previousState: GKState?) {
    guard let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) else { return }
    
    spriteComponent.node.removeAllActions()
    spriteComponent.node.texture = SKTexture(imageNamed: "amber-jump-middle")
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    guard let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) else { return }

    if (spriteComponent.node.physicsBody?.velocity.dy)! < -300 {
      spriteComponent.node.texture = SKTexture(imageNamed: "amber-jump-down")
    }
  }
}
