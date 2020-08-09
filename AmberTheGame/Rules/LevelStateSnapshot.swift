/*
 Abstract: Данные классы используются игровым ИИ для захвата и оценки снимка состояния игры.
 `EntityDistance` - инкапсулирует расстояние между двумя объектами.
 `LevelStateSnapshot` = хранит `EntitySnapshot` для каждой сущности уровня.
 `EntitySnapshot` хранит расстояния от сущности до любой другй сущности на уровне.
 */

import GameplayKit

/// Инкапсулирует две сущности и их расстояние друг от друга.
struct EntityDistance {
  let source: GKEntity
  let target: GKEntity
  let distance: Float
}

/**
 Хранит снимок состояния уровня и всех его entities
 (`Enemy`s и `Amber`) в определенный момент
 */
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
    
    // Словарь, который будет содержать временный массив экземпляров EntityDistance для каждой сущности.
    var entityDistances: [GKEntity: [EntityDistance]] = [:]
    
    // Добавляем (временно) пустой массив в словарь для каждой сущности.
    for entity in scene.entityManager.entities {
      entityDistances[entity] = []
    }
    
    /*
     Переберите все сущности на сцене, чтобы вычислить их расстояние от других сущностей.
     `scene.entityManager.entities` - это` Set`, который не имеет целочисленной индексации.
     Поскольку мы хотим использовать текущее значение индекса из внешнего цикла в качестве начального числа для внутреннего цикла,
     мы работаем со значениями индекса `Set` напрямую.
     */
    for sourceEntity in scene.entityManager.entities {
      let sourceIndex = scene.entityManager.entities.firstIndex(of: sourceEntity)!
      
      // Получаем `GKAgent`.
      let sourceAgent = agentForEntity(entity: sourceEntity)
      
      // Перебираем оставшиеся сущности, чтобы вычислить их расстояние от исходного агента.
      for targetEntity in scene.entityManager.entities[scene.entityManager.entities.index(after: sourceIndex) ..< scene.entityManager.entities.endIndex] {
        // Получаем `GKAgent`.
        let targetAgent = agentForEntity(entity: targetEntity)
        
        // Рассчитываем расстояние между двумя агентами.
        let dx = targetAgent.position.x - sourceAgent.position.x
        let dy = targetAgent.position.y - sourceAgent.position.y
        let distance = hypotf(dx, dy)
        
        // Записываем расстояния в массив как для исходного так и для перебираемого
        entityDistances[sourceEntity]!.append(EntityDistance(source: sourceEntity, target: targetEntity, distance: distance))
        entityDistances[targetEntity]!.append(EntityDistance(source: targetEntity, target: sourceEntity, distance: distance))
      }
    }
    
    // Создаем моментальный снимок объекта в словаре entitySnapshots для каждого объекта.
    for entity in scene.entityManager.entities {
      let entitySnapshot = EntitySnapshot(entityDistances: entityDistances[entity]!)
      entitySnapshots[entity] = entitySnapshot
    }
  }
}

class EntitySnapshot {
  // MARK: - Properties
  
  /// Коэффициент, используемый для нормализации  расстояний между персонажами  для  "Fuzzy rules"
  let proximityFactor: Float = 800
  
  /// Расстояние до `Amber`
  let amberTarget: (target: Amber, distance: Float)?
  
  /// Отсортированный массив расстояний от текущего объекта до каждого другого объекта на уровне.
  let entityDistances: [EntityDistance]
  
  
  // MARK: - Initialization
  
  init(entityDistances: [EntityDistance]) {
    
    // Сортируем массив `entityDistances` по расстоянию (ближайший первый), сохраняем отсортированную версию.
    self.entityDistances = entityDistances.sorted {
      return $0.distance < $1.distance
    }
    
    var amberTarget: (target: Amber, distance: Float)?
    
    /*
     Перебираем отсортированный массив entityDistances, чтобы найти `Amber`
     */
    for entityDistance in self.entityDistances {
      if let target = entityDistance.target as? Amber, amberTarget == nil {
        amberTarget = (target: target, distance: entityDistance.distance)
      }
      
      // Прекращаем итерацию по массиву, как только мы найдем `Amber`
      if amberTarget != nil {
        break
      }
    }
    
    self.amberTarget = amberTarget
  }
}
