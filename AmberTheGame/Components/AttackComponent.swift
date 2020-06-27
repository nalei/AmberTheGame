import SpriteKit
import GameplayKit

class AttackComponent: GKComponent {
  let hitBox = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
  
  func hit() {
    if let animationComponent = entity?.component(ofType: AnimationComponent.self) {
      animationComponent.stateMachine?.enter(HitState.self)
    }
  }
}
