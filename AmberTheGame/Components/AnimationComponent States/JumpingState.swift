import GameplayKit
import SpriteKit

class JumpingState : GKState {
  // MARK: - Properties
  
  unowned var entity: GKEntity
  
  var jumpUpAnimation: SKTexture
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = entity.component(ofType: SpriteComponent.self) else {
      fatalError("A JumpingState's entity must have an SpriteComponent.")
    }
    return spriteComponent
  }
  
  // MARK: - Initializers
  
  required init(entity: GKEntity, jumpUpAnimation: SKTexture?) {
    self.entity = entity
    self.jumpUpAnimation = jumpUpAnimation! // !!!
  }
  
  
  // MARK: - GKState Life Cycle
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    spriteComponent.node.texture = jumpUpAnimation
    
    spriteComponent.launchJumpParticleEffect()

    spriteComponent.squashAndSretch(xScale: 0.7, yScale: 1.4)
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)

    if (spriteComponent.node.physicsBody?.velocity.dy)! < 0 {
      stateMachine?.enter(FallingState.self)
    }
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is IdleState.Type, is WalkingState.Type, is FallingState.Type, is HitState.Type, is DamageState.Type:
      return true
    case is JumpingState.Type:
      return false
    default:
      return false
    }
  }
}
