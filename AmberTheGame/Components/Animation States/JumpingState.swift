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
      return true
    default:
      return false
    }
  }
  
  override func didEnter(from previousState: GKState?) {
    if let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) {
      let spriteNode = spriteComponent.node
      spriteNode.removeAllActions()
      spriteNode.texture = SKTexture(imageNamed: "amber-jump-up")
      
      squashAndSretch(spriteNode, xScale: 0.7 * spriteNode.xScale, yScale: 1.3)
    }
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    if let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) {
      let spriteNode = spriteComponent.node
      if (spriteNode.physicsBody?.velocity.dy)! < -0.1 {
        spriteNode.texture = SKTexture(imageNamed: "amber-jump-middle")
      }
    }
  }
  
  func squashAndSretch(_ node: SKSpriteNode, xScale: CGFloat, yScale: CGFloat) {
    node.xScale = xScale
    node.yScale = yScale
  }
}
