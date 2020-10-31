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
      
    } else {
      spriteComponent.node.run(animationComponent.damage!, withKey: "damage")
    }
    
    // Анимация: меняет цвет спрайта на белый, в течение 0.15c.
    let pulsedWhite = SKAction.sequence([
      SKAction.run({
        let whiteColorShader = SKShader(source: "void main() { " +
                                          "    vec4 current_color = SKDefaultShading(); " +
                                          "    if (current_color.a > 0.0) { " +
                                          "        gl_FragColor = vec4(1,1,1,1); " +
                                          "    } else {" +
                                          "        gl_FragColor = current_color; " +
                                          "    } " +
                                          "} ")
        self.spriteComponent.node.shader = whiteColorShader
      }),
      SKAction.wait(forDuration: 0.15),
      SKAction.run({
        self.spriteComponent.node.shader = nil
      })
    ])
      
    spriteComponent.node.run(pulsedWhite)
    
    // Прерываем управление персонажем, пока он находится в `DamageState`.
    if let inputComponent = animationComponent.entity?.component(ofType: InputComponent.self) {
      inputComponent.isEnabled = false;
    }
    
    //Наносим дамаг
    if let attackComponent = animationComponent.entity?.component(ofType: AttackComponent.self) {
      attackComponent.damageSelf()
    }
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    // Обновляем счетчик времени в состоянии `DamageState`.
    elapsedTime += seconds
    
    if elapsedTime >= 0.6 {
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
      return spriteComponent.node.action(forKey: "damage") == nil
    case is DamageState.Type:
      return false
    default:
      return false
    }
  }
}
