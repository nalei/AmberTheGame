import SpriteKit
import GameplayKit

class WalkingState: GKState {
  unowned var animationComponent: AnimationComponent
  
  /// The `SpriteComponent` associated with the `AnimationComponent`'s `entity`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) else {
      fatalError("A WalkingState's entity must have a SpriteComponent")
    }
    return spriteComponent
  }
  
  required init(animationComponent: AnimationComponent) {
    self.animationComponent = animationComponent
  }
  
  override func didEnter(from previousState: GKState?) {
    let spriteNode = spriteComponent.node
    spriteNode.run(SKAction(named: "RunAnim")!, withKey: "RunAnim")
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is WalkingState.Type
  }
}
