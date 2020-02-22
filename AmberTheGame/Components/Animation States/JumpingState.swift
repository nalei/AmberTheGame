import GameplayKit
import SpriteKit

class JumpingState : GKState {
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
      return false
    default:
      return false
    }
  }
  
  override func didEnter(from previousState: GKState?) {
    if let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) {
      spriteComponent.node.removeAllActions()
      spriteComponent.node.texture = SKTexture(imageNamed: "amber-jump-up")
      
      spriteComponent.squashAndSretch(xScale: 0.7, yScale: 1.4)
    }
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    if let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) {
      if (spriteComponent.node.physicsBody?.velocity.dy)! < -0.1 {
        spriteComponent.node.texture = SKTexture(imageNamed: "amber-jump-middle")
      }
    }
  }
}
