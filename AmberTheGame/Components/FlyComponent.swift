import SpriteKit
import GameplayKit

class FlyComponent: GKAgent2D, GKAgentDelegate {
  let entityManager: EntityManager
  
  init(maxSpeed: Float, maxAcceleration: Float, radius: Float, entityManager: EntityManager) {
    self.entityManager = entityManager
    super.init()
    delegate = self
    self.maxSpeed = maxSpeed
    self.maxAcceleration = maxAcceleration
    self.radius = radius
    self.mass = 0.01
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
  
  /// Возвращает FlyComponent игрока
  func getAmberMoveComponent() -> GKAgent2D? {
    let playerEntity = entityManager.getAmberEntity()
    return playerEntity?.component(ofType: FlyComponent.self)
  }
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    guard let amberMoveComponent = getAmberMoveComponent() else {
      return
    }
    
    if let spriteComponent = entity?.component(ofType: SpriteComponent.self) {
      if velocity.x < 0 {
        spriteComponent.node.xScale = -1
      }
      if velocity.x > 0 {
        spriteComponent.node.xScale = 1
      }
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
