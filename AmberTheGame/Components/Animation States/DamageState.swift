import SpriteKit
import GameplayKit

class DamageState: GKState {
  // MARK: - Properties
  unowned var animationComponent: AnimationComponent
  
  /// Время, в течение которого объект находился в состоянии `DamageState`.
  var elapsedTime: TimeInterval = 0.0
  
  /// Используется если во время получения урона необходимо продолжить проведение атаки
  var damageAndHit = false
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = animationComponent.entity?.component(ofType: SpriteComponent.self) else {
      fatalError("A HitState's entity must have an SpriteComponent.")
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
    
    // Не запускаем анимацию damage для `Skeleton` если он в состоянии удара
    if (animationComponent.entity is Skeleton) && (previousState is HitState) {
      damageAndHit = true
    } else {
      spriteComponent.node.run(animationComponent.damage!, withKey: "damage")
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
    
    // Анимация: меняет цвет спрайта на белый, в течение 0.15c.
//    let pulsedWhite = SKAction.sequence([
//      SKAction.run({
//        let whiteColorShader = SKShader(source: "void main() { " +
//                                          "    vec4 current_color = SKDefaultShading(); " +
//                                          "    if (current_color.a > 0.0) { " +
//                                          "        gl_FragColor = vec4(1,1,1,1); " +
//                                          "    } else {" +
//                                          "        gl_FragColor = current_color; " +
//                                          "    } " +
//                                          "} ")
//        self.spriteComponent.node.shader = whiteColorShader
//      }),
//      SKAction.wait(forDuration: 0.15),
//      SKAction.run({
//        self.spriteComponent.node.shader = nil
//      })
//    ])
//
//    spriteComponent.node.run(pulsedWhite)
    
    // Прерываем управление персонажем, пока он находится в `DamageState`.
    if let inputComponent = animationComponent.entity?.component(ofType: InputComponent.self) {
      inputComponent.isEnabled = false;
    }
    
    //Наносим дамаг
    if let attackComponent = animationComponent.entity?.component(ofType: AttackComponent.self) {
      attackComponent.applyDamageToEntity()
    }
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    // Обновляем счетчик времени в состоянии `DamageState`.
    elapsedTime += seconds
    
    if damageAndHit {
      let startDamageTime = 0.4
      let endDamageTime = 0.6
      
      if let attackComponent = animationComponent.entity?.component(ofType: AttackComponent.self) {
        // Добавляем `hitBox` в промежутке между `startDamageTime` и `endDamageTime` нахождения в состояни `HitState`.
        if elapsedTime >= startDamageTime && elapsedTime <= endDamageTime {
          if attackComponent.hitBox.parent == nil {
            spriteComponent.node.addChild(attackComponent.hitBox)
          }
        } else {
          if attackComponent.hitBox.parent != nil {
            attackComponent.hitBox.removeFromParent()
          }
        }
      }
    }
    
    if elapsedTime >= 0.6 {
      stateMachine?.enter(IdleState.self)
    }
  }
  
  override func willExit(to nextState: GKState) {
    super.willExit(to: nextState)
    
    damageAndHit = false
    
    spriteComponent.node.removeAction(forKey: "damage")
    
    if let inputComponent = animationComponent.entity?.component(ofType: InputComponent.self) {
      inputComponent.isEnabled = true;
    }
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    switch stateClass {
    case is IdleState.Type, is WalkingState.Type, is JumpingState.Type, is FallingState.Type, is HitState.Type:
      return spriteComponent.node.action(forKey: "damage") == nil
    case is DamageState.Type:
      return false
    default:
      return false
    }
  }
}
