import SpriteKit
import GameplayKit

class AttackComponent: GKComponent {
  // MARK: - Properties
  var hp: Int
  
  let hitBox: SKSpriteNode
  
  let hurtBox: SKSpriteNode
  
  /// Вычисляемое свойство указывающее на `SpriteComponent`.
  var spriteComponent: SpriteComponent {
    guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
      fatalError("A AttackComponent's entity must have a SpriteComponent")
    }
    return spriteComponent
  }
  
  
  // MARK: - Initializers
  
  init(hp: Int) {
    self.hp = hp
    self.hitBox = SKSpriteNode(color: .clear, size: .zero)
    self.hurtBox = SKSpriteNode(color: .clear, size: .zero)
    
    super.init()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - GKComponent Life Cycle
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    if let animationComponent = entity?.component(ofType: AnimationComponent.self) {
      if animationComponent.stateMachine?.currentState is HitState {
        damageEnemy()
      }
    }
  }
  
  public func hit() {
    if let animationComponent = entity?.component(ofType: AnimationComponent.self) {
      animationComponent.stateMachine?.enter(HitState.self)
    }
  }
  
  public func damageSelf() {
    hp -= 1
    
    if hp == 0 {
      // Переносим `Amber` к ближайшему чекпоинту
      if let _ = entity as? Amber {
        print("Game over!")
      }
    }
    
    bounceBack(force: 100)
  }
  
  /// Перебираем все объекты сцены, если `hitBox` и `hurtBox` пересекаются, то объект содержащий `hurtBox` получает damage
  private func damageEnemy() {
    guard let levelScene = spriteComponent.node.scene as? LevelScene else { return }
    
    levelScene.entityManager.entities.forEach { enemy in
      
      if let enemyHurtBox = enemy.component(ofType: AttackComponent.self)?.hurtBox {
        if self.hitBox.intersects(enemyHurtBox) {
          
          // Откидываем `Amber` назад, при попадании по врагу
          if let _ = entity as? Amber {
            bounceBack(force: 10)
          }
          
          if let enemyAnimationComponent = enemy.component(ofType: AnimationComponent.self) {
            if ((enemy as? Skeleton) != nil) && enemyAnimationComponent.stateMachine?.currentState is HitState {
              // Не дамажим скелета если он в состоянии удара
            } else {
              enemyAnimationComponent.stateMachine?.enter(DamageState.self)
            }
          }
        }
      }
    }
    
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
