import SpriteKit
import GameplayKit

class DamageState: GKState {
  // MARK: - Properties
  unowned var animationComponent: AnimationComponent
  
  /// Время, в течение которого объект находился в состоянии `DamageState`.
  var elapsedTime: TimeInterval = 0.0
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) else {
      fatalError("A DamageState's entity must have an SpriteComponent.")
    }
    return spriteComponent
  }
  
  
  // MARK: - Initializers
  
  required init(animationComponent: AnimationComponent) {
    self.animationComponent = animationComponent
  }
  
  
  // MARK: - GKState Life Cycle
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
    // Сбросываем счетчик времени при входе в это состояние.
    elapsedTime = 0.0
    
    spriteComponent.node.run(animationComponent.damage!, withKey: "damage")
    
    // Прерываем управление персонажем, пока он находится в `DamageState`.
    if let inputComponent = animationComponent.entity?.component(ofType: InputComponent.self) {
      inputComponent.isEnabled = false;
    }
    
    if spriteComponent.entity is Amber {
      // Анимация: трясем экран
      if let cameraNode = spriteComponent.node.scene?.camera {
        cameraNode.run(SKAction.shake(initialPosition: cameraNode.position, duration: 0.9, amplitudeX: 12, amplitudeY: 40))
      }
      
      // Создаем, запускаем и удаляем эмиттер частиц для прыжка
      if let levelScene = spriteComponent.node.scene as? LevelScene, let jumpEmitter = SKEmitterNode(fileNamed: "jump.sks") {
        jumpEmitter.targetNode = levelScene
        jumpEmitter.particleZPosition = -1
        jumpEmitter.position = CGPoint(x: 0, y: 29)
        spriteComponent.node.addChild(jumpEmitter)
        
        let emitterDuration = Double(jumpEmitter.numParticlesToEmit) / Double(jumpEmitter.particleBirthRate) + Double(jumpEmitter.particleLifetime + jumpEmitter.particleLifetimeRange/2)
        let wait = SKAction.wait(forDuration: TimeInterval(emitterDuration))
        let remove = SKAction.removeFromParent()
        jumpEmitter.run(SKAction.sequence([wait, remove]))
      }
    }
    
    spriteComponent.squashAndSretch(xScale: 1.3, yScale: 0.7)
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    // Обновляем счетчик времени в состоянии `DamageState`.
    elapsedTime += seconds
    
    if elapsedTime >= 0.4 {
      stateMachine?.enter(IdleState.self)
    }
  }
  
  override func willExit(to nextState: GKState) {
    super.willExit(to: nextState)
    
    spriteComponent.node.removeAction(forKey: "damage")
    
    if let inputComponent = animationComponent.entity?.component(ofType: InputComponent.self) {
      inputComponent.isEnabled = true;
    }
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
