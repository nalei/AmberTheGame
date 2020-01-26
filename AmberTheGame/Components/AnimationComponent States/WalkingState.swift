import SpriteKit
import GameplayKit

class WalkingState: GKState {
  var spriteNode: SKSpriteNode?
  var animation: SKAction
  
  init(with entity: Amber, animation: SKAction) {
    if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node {
      self.spriteNode = spriteNode
    }
    self.animation = animation
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is IdleState.Type:
      return true
    default:
      return false
    }
  }
  
  override func didEnter(from previousState: GKState?) {
    spriteNode?.run(animation)
  }
}
