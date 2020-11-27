import SpriteKit
import GameplayKit

class AttackComponent: GKComponent {
  // MARK: - Properties
  var hp: Int
  
  let hitBox: SKSpriteNode
  
  let hurtBox: SKSpriteNode
  
  var stateMachine: GKStateMachine
  
  let initialStateClass: AnyClass
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
      fatalError("A AttackComponent's entity must have a SpriteComponent")
    }
    return spriteComponent
  }
  
  
  // MARK: - Initializers
  
  init(hp: Int, states: [GKState]) {
    self.hp = hp
    hitBox = SKSpriteNode(color: .clear, size: .zero)
    hurtBox = SKSpriteNode(color: .clear, size: .zero)
    
    stateMachine = GKStateMachine(states: states)
    let firstState = states.first!
    initialStateClass = type(of: firstState)
    
    super.init()
    
    self.enterInitialState()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - GKComponent Life Cycle
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    if stateMachine.currentState is AttackState {
      damageEnemy()
    }
    
    stateMachine.update(deltaTime: seconds)
  }
  
  
  // MARK: - Actions
  
  public func enterInitialState() {
    stateMachine.enter(initialStateClass)
  }
  
  public func hit() {
    stateMachine.enter(AttackState.self)
    
    if let animationComponent = entity?.component(ofType: AnimationComponent.self) {
      animationComponent.stateMachine?.enter(HitState.self)
    }
  }
  
  public func applyDamageToSelf() {
    guard let levelScene = spriteComponent.node.scene as? LevelScene else { return }
    
    hp -= 1
    
    // Анимация: меняет цвет спрайта на белый, в течение 0.15c.
    spriteComponent.node.run(SKAction.pulsedWhite(node: spriteComponent.node))
    
    if hp == 0 {
      if let enemy = entity as? Enemy {
        levelScene.entityManager.remove(enemy)
      }
    } else {
      if entity is Amber {
        bounceBack(force: 160)
      }
    }
  }
  
  
  // MARK: - Convenience
  
  /// Перебираем все объекты сцены, если `hitBox` и `hurtBox` пересекаются, то объект содержащий `hurtBox` получает damage
  private func damageEnemy() {
    guard let levelScene = spriteComponent.node.scene as? LevelScene else { return }
    
    levelScene.entityManager.entities.forEach { enemy in
      
      if let enemyHurtBox = enemy.component(ofType: AttackComponent.self)?.hurtBox {
        if self.hitBox.intersects(enemyHurtBox) {
          
          if let enemyAttackComponent = enemy.component(ofType: AttackComponent.self) {
            enemyAttackComponent.stateMachine.enter(DamagedState.self)
          }
          
          // Анимация
          if let enemyAnimationComponent = enemy.component(ofType: AnimationComponent.self) {
            
            if enemy is Skeleton && enemyAnimationComponent.stateMachine?.currentState is HitState {
              // Не меняем состояние на `damageState` для `Skeleton` если он в состоянии удара
            } else {
              // Переводим объект в `damageState`
              enemyAnimationComponent.stateMachine?.enter(DamageState.self)
            }
          }
          
          // Откидываем `Amber` назад, при попадании по врагу
          if entity is Amber {
            bounceBack(force: 20)
          }
        }
      }
    }
    
    // Откидываем объект назад, при попадании по элементам `ForegroundMap`
    if let foregroundMap = levelScene.childNode(withName: "ForegroundMap") as? SKTileMapNode {
      foregroundMap["Ground"].forEach { node in
        if self.hitBox.intersects(node) {
          bounceBack(force: 10)
        }
      }
    }
  }
  
  private func bounceBack(force: CGFloat) {
    if let physicsComponent = entity?.component(ofType: PhysicsComponent.self) {
      physicsComponent.physicsBody.applyImpulse(CGVector(dx: (-spriteComponent.node.xScale * force), dy: 0.0))
    }
  }
}
