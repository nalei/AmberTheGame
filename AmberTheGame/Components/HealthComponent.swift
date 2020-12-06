import SpriteKit
import GameplayKit

class HealthComponent: GKComponent {
  // MARK: - Properties
  
  /**
   The state machine for this `HealthComponent`. Defined as an implicitly
   unwrapped optional property, because it is created during initialization,
   but cannot be created until after we have called super.init().
   */
  var stateMachine: GKStateMachine!
  
  var hp: Int
  
  let hitBox: SKSpriteNode
  let hurtBox: SKSpriteNode
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
      fatalError("A HealthComponent's entity must have a SpriteComponent")
    }
    return spriteComponent
  }
  
  
  // MARK: - Initializers
  
  init(hp: Int) {
    self.hp = hp
    hitBox = SKSpriteNode(color: .clear, size: .zero)
    hurtBox = SKSpriteNode(color: .clear, size: .zero)
    
    super.init()
    
    stateMachine = GKStateMachine(states: [
      HealthIdleState(healthComponent: self),
      HealthDamageState(healthComponent: self)
    ])
    
    stateMachine.enter(HealthIdleState.self)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - GKComponent Life Cycle
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    if let animationComponent = entity?.component(ofType: AnimationComponent.self) {
      if animationComponent.stateMachine.currentState is HitState {
        damageEnemy()
      }
    }
    
    stateMachine.update(deltaTime: seconds)
  }
  
  
  // MARK: - Actions
  
  public func hit() {
    if let animationComponent = entity?.component(ofType: AnimationComponent.self) {
      animationComponent.stateMachine.enter(HitState.self)
    }
  }
  
  public func damage() {
    self.stateMachine.enter(HealthDamageState.self)
    
    // Анимация
    if let animationComponent = entity?.component(ofType: AnimationComponent.self) {
      
      if entity is Skeleton && animationComponent.stateMachine.currentState is HitState {
        // Не меняем состояние на `damageState` для `Skeleton` если он в состоянии удара
      } else {
        animationComponent.stateMachine.enter(DamageState.self)
      }
    }
  }
  
  public func death() {
    guard let levelScene = spriteComponent.node.scene as? LevelScene else { return }
    
    if let enemy = entity as? Enemy {
      levelScene.entityManager.remove(enemy)
    }
  }
  
  
  // MARK: - Convenience
  
  /// Перебираем все объекты сцены, если `hitBox` и `hurtBox` пересекаются, то объект содержащий `hurtBox` получает damage
  private func damageEnemy() {
    guard let levelScene = spriteComponent.node.scene as? LevelScene else { return }
    
    levelScene.entityManager.entities.forEach { enemy in
      
      if let enemyHurtBox = enemy.component(ofType: HealthComponent.self)?.hurtBox {
        if self.hitBox.intersects(enemyHurtBox) {
          
          // Damage
          if let enemyHealthComponent = enemy.component(ofType: HealthComponent.self) {
            enemyHealthComponent.damage()
          }
          
          // Откидываем `Amber` назад, при попадании по врагу
          if entity is Amber {
            spriteComponent.bounceBack(force: 20)
          }
        }
      }
    }
    
    // Откидываем объект назад, при попадании по элементам `ForegroundMap`
    if let foregroundMap = levelScene.childNode(withName: "ForegroundMap") as? SKTileMapNode {
      foregroundMap["Ground"].forEach { node in
        if self.hitBox.intersects(node) {
          spriteComponent.bounceBack(force: 10)
        }
      }
    }
  }
}
