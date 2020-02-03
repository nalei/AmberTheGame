import SpriteKit
import GameplayKit

class IdleState: GKState {
  unowned var animationComponent: AnimationComponent
  
  required init(animationComponent: AnimationComponent) {
    self.animationComponent = animationComponent
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is IdleState.Type:
      return false
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
      spriteNode.texture = SKTexture(imageNamed: "amber-idle")
      
      if let _ = previousState as? JumpingState {
        squashAndSretch(spriteNode, xScale: 1.3 * spriteNode.xScale, yScale: 0.7)
      }
    }
  }
  
  func squashAndSretch(_ node: SKSpriteNode, xScale: CGFloat, yScale: CGFloat) {
    node.xScale = xScale
    node.yScale = yScale
  }
}
