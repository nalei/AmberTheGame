import SpriteKit
import GameplayKit

class EnemyMoveComponent: GKAgent2D, GKAgentDelegate {
  let entityManager: EntityManager
  
  init(maxSpeed: Float, maxAcceleration: Float, radius: Float, entityManager: EntityManager) {
    self.entityManager = entityManager
    super.init()
    delegate = self
    self.maxSpeed = maxSpeed
    self.maxAcceleration = maxAcceleration
    self.radius = radius
    self.mass = 0.01
    print(self.mass)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// Прежде чем агент обновит позицию, устанавливаем агента в позицию спрайта
  func agentWillUpdate(_ agent: GKAgent) {
    guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
      return
    }
    
    position = vector_float2(spriteComponent.node.position)
  }
  
  /// После того, как агент обновит позицию, устанавливаем спрайт в позицию агента
  func agentDidUpdate(_ agent: GKAgent) {
    guard let spriteComponent = entity?.component(ofType: SpriteComponent.self) else {
      return
    }
    
    spriteComponent.node.position = CGPoint(position)
  }
  
  /// Возвращает EnemyMoveComponent игрока
  func getPlayerMoveComponent() -> GKAgent2D? {
    let playerEntity = entityManager.getPlayerEntity()
    return playerEntity?.component(ofType: EnemyMoveComponent.self)
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    guard let amberMoveComponent = getPlayerMoveComponent() else {
      return
    }
    
    // Поведение
    behavior = EnemyMoveBehavior(targetSpeed: maxSpeed, seek: amberMoveComponent)
  }
}


// MARK: - Points and vectors

extension CGPoint {
  init(_ point: vector_float2) {
    self.init()
    x = CGFloat(point.x)
    y = CGFloat(point.y)
  }
}

extension vector_float2 {
  init(_ point: CGPoint) {
    self.init(x: Float(point.x), y: Float(point.y))
  }
}
