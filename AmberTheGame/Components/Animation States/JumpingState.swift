import GameplayKit
import SpriteKit

class JumpingState : GKState {
  unowned var animationComponent: AnimationComponent
  
  required init(animationComponent: AnimationComponent) {
    self.animationComponent = animationComponent
  }
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    guard let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) else { return }
    
    spriteComponent.node.removeAllActions()
    spriteComponent.node.texture = animationComponent.jumpUp
    
    if let levelScene = spriteComponent.node.scene as? LevelScene, let missileEmitter = SKEmitterNode(fileNamed: "jump.sks") {
      missileEmitter.targetNode = levelScene
      missileEmitter.particleZPosition = -1
      missileEmitter.name = "MissileEmitter"
      spriteComponent.node.addChild(missileEmitter)
      
      let emitterDuration = Double(missileEmitter.numParticlesToEmit) / Double(missileEmitter.particleBirthRate) + Double(missileEmitter.particleLifetime + missileEmitter.particleLifetimeRange/2)
      let wait = SKAction.wait(forDuration: TimeInterval(emitterDuration))
      let remove = SKAction.removeFromParent()
      missileEmitter.run(SKAction.sequence([wait, remove]))
    }

    spriteComponent.squashAndSretch(xScale: 0.7, yScale: 1.4)
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    guard let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) else { return }

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
