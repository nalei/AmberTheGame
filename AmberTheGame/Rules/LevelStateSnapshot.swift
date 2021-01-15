/*
 Данные классы используются игровым ИИ для захвата и оценки снимка состояния игры.
 `EntityDistance` - инкапсулирует расстояние до объекта.
 `LevelStateSnapshot` = Хранит `EntitySnapshot` для всех `Enemy`
 `EntitySnapshot` хранит расстояния от сущности до `Amber`.
 */

import GameplayKit

/// Инкапсулирует сущность и расстояние до нее.
struct EntityDistance {
  let target: GKEntity
  let distance: Float
}


/// Хранит `EntitySnapshot` для всех `Enemy`
class LevelStateSnapshot {
  // MARK: - Properties
  
  /// Словарь, ключи которого являются сущностями, а значения - моментальными снимками  для этих сущностей.
  var entitySnapshots: [GKEntity: EntitySnapshot] = [:]
  
  
  // MARK: - Initialization
  
  init(scene: LevelScene) {
    
    /// Возвращает  `GKAgent2D` для `Amber` или `Enemy`.
    func agentForEntity(entity: GKEntity) -> GKAgent2D {
      if let agent = entity.component(ofType: AgentComponent.self) {
        return agent
      }
      else if let amber = entity as? Amber {
        return amber.agent
      }
      
      return GKAgent2D()
    }
    
    // Обходим все объекты на сцене, чтобы вычислить моментальнвй снимок для каждого `Enemy`.
    for entity in scene.entityManager.entities {
      
      if let sourceEntity = entity as? Enemy, let targetEntity = scene.entityManager.character {
        // Получаем `GKAgent2D`.
        let sourceAgent = agentForEntity(entity: sourceEntity)
        let targetAgent = agentForEntity(entity: targetEntity)
        
        // Рассчитываем расстояние между двумя агентами.
        let dx = targetAgent.position.x - sourceAgent.position.x
        let dy = targetAgent.position.y - sourceAgent.position.y
        let distance = hypotf(dx, dy)
        
        let entityDistance = EntityDistance(target: targetEntity, distance: distance)
        let entitySnapshot = EntitySnapshot(entityDistance: entityDistance)
        entitySnapshots[sourceEntity] = entitySnapshot
      }
    }
  }
}

class EntitySnapshot {
  // MARK: - Properties
  
  /// Коэффициент, используемый для нормализации  расстояний между персонажами  для  "Fuzzy rules"
  let proximityFactor: Float = 700
  
  /// Расстояние до `Amber`
  var amberTarget: (target: Amber, distance: Float)?
  
  // MARK: - Initialization
  
  init(entityDistance: EntityDistance) {
    
    if let target = entityDistance.target as? Amber {
      self.amberTarget = (target: target, distance: entityDistance.distance)
    }
  }
}
