import SpriteKit
import GameplayKit

class DamageState: GKState {
  // MARK: - Properties
  
  unowned var entity: GKEntity
  
  var damageAnimation: SKAction
  
  /// Время, в течение которого объект находился в состоянии `DamageState`.
  var elapsedTime: TimeInterval = 0.0
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = entity.component(ofType: SpriteComponent.self) else {
      fatalError("A DamageState's entity must have an SpriteComponent.")
    }
    return spriteComponent
  }
  
  
  // MARK: - Initializers
  
  required init(entity: GKEntity, damageAnimation: SKAction?) {
    self.entity = entity
    self.damageAnimation = damageAnimation! // !!!
  }
  
  
  // MARK: - GKState Life Cycle
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    // Сбросываем счетчик времени при входе в это состояние.
    elapsedTime = 0.0
    
    spriteComponent.node.run(damageAnimation, withKey: "damage")
    
    if entity is Amber {
      spriteComponent.launchJumpParticleEffect()
    }
    
    spriteComponent.squashAndSretch(xScale: 1.3, yScale: 0.7)
  }
  
  
  // MARK: - Actions
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    // Обновляем счетчик времени в состоянии `DamageState`.
    elapsedTime += seconds
    
    if elapsedTime >= GameplayConfiguration.Amber.damageStateDuration {
      stateMachine?.enter(IdleState.self)
    }
  }
  
  override func willExit(to nextState: GKState) {
    super.willExit(to: nextState)
    
    spriteComponent.node.removeAction(forKey: "damage")
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is IdleState.Type, is WalkingState.Type, is JumpingState.Type, is FallingState.Type, is HitState.Type:
      return true
    case is DamageState.Type:
      return false
    default:
      return false
    }
  }
}
