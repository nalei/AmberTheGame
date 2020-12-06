import GameplayKit
import SpriteKit

class FallingState : GKState {
  // MARK: - Properties
  
  unowned var entity: GKEntity
  
  var jumpMiddleAnimation: SKTexture
  var jumpDownAnimation: SKTexture
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = entity.component(ofType: SpriteComponent.self) else {
      fatalError("A FallingState's entity must have an SpriteComponent.")
    }
    return spriteComponent
  }
  
  // MARK: - Initializers
  
  required init(entity: GKEntity, jumpMiddleAnimation: SKTexture?, jumpDownAnimation: SKTexture?) {
    self.entity = entity
    self.jumpMiddleAnimation = jumpMiddleAnimation! // !!!
    self.jumpDownAnimation = jumpDownAnimation! // !!!
  }
  
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    spriteComponent.node.texture = jumpMiddleAnimation
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    if (spriteComponent.node.physicsBody?.velocity.dy)! < -400 {
      spriteComponent.node.texture = jumpDownAnimation
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
