///*
// Abstract: Данные типы используются игровым ИИ для захвата и оценки снимка состояния игры.
// `EntityDistance` - инкапсулирует расстояние между двумя объектами.
// `LevelStateSnapshot` = хранит `EntitySnapshot` для каждой сущности уровня.
// `EntitySnapshot` хранит расстояния от сущности до любой другй сущности на уровне.
// */
//
//import GameplayKit
//
///// Инкапсулирует две сущности и их расстояние друг от друга.
//struct EntityDistance {
//  let source: GKEntity
//  let target: GKEntity
//  let distance: Float
//}
//
///**
// Хранит снимок состояния уровня и всех его entities
// (`Enemy`s и `Amber`) в определенный момент
// */
//class LevelStateSnapshot {
//  // MARK: - Properties
//
//  /// Словарь, ключи которого являются сущностями, а значения - моментальными снимками  для этих сущностей.
//  var entitySnapshots: [GKEntity: EntitySnapshot] = [:]
//
//
//  // MARK: - Initialization
//
//  init(scene: LevelScene) {
//
//    /// Возвращает  `GKAgent2D` для `Amber` или `Enemy`.
//    func agentForEntity(entity: GKEntity) -> GKAgent2D {
//      if let agent = entity.component(ofType: AgentComponent.self) {
//        return agent
//      }
//      else if let amber = entity as? Amber {
//        return amber.agent
//      }
//
//      fatalError("All entities in a level must have an accessible associated GKEntity")
//    }
//
//    // Словарь, который будет содержать временный массив экземпляров EntityDistance для каждой сущности.
//    var entityDistances: [GKEntity: [EntityDistance]] = [:]
//
//    // Добавляем (временно) пустой массив в словарь для каждой сущности.
//    for entity in scene.entities {
//      entityDistances[entity] = []
//    }
//
//    /*
//     Переберите все сущности на сцене, чтобы вычислить их расстояние от других сущностей.
//     `scene.entities` - это` Set`, который не имеет целочисленной индексации.
//     Поскольку мы хотим использовать текущее значение индекса из внешнего цикла в качестве начального числа для внутреннего цикла,
//     мы работаем со значениями индекса `Set` напрямую.
//     */
//    for sourceEntity in scene.entities {
//      let sourceIndex = scene.entities.firstIndex(of: sourceEntity)!
//
//      // Получаем `GKAgent`.
//      let sourceAgent = agentForEntity(entity: sourceEntity)
//
//      // Перебираем оставшиеся сущности, чтобы вычислить их расстояние от исходного агента.
//      for targetEntity in scene.entities[scene.entities.index(after: sourceIndex) ..< scene.entities.endIndex] {
//        // Получаем `GKAgent`.
//        let targetAgent = agentForEntity(entity: targetEntity)
//
//        // Рассчитываем расстояние между двумя агентами.
//        let dx = targetAgent.position.x - sourceAgent.position.x
//        let dy = targetAgent.position.y - sourceAgent.position.y
//        let distance = hypotf(dx, dy)
//
//        // Записываем расстояния в массив как для исходного так и для перебираемого
//        entityDistances[sourceEntity]!.append(EntityDistance(source: sourceEntity, target: targetEntity, distance: distance))
//        entityDistances[targetEntity]!.append(EntityDistance(source: targetEntity, target: sourceEntity, distance: distance))
//      }
//    }
//
//    // Determine the number of "good" `TaskBot`s and "bad" `TaskBot`s in the scene.
//    let (goodTaskBots, badTaskBots) = scene.entities.reduce(([], [])) {
//
//      (workingArrays: (goodBots: [TaskBot], badBots: [TaskBot]), thisEntity: GKEntity) -> ([TaskBot], [TaskBot]) in
//
//      // Try to cast this entity as a `TaskBot`, and skip this entity if the cast fails.
//      guard let thisTaskBot = thisEntity as? TaskBot else { return workingArrays }
//
//      // Add this `TaskBot` to the appropriate working array based on whether it is "good" or not.
//      if thisTaskBot.isGood {
//        return (workingArrays.goodBots + [thisTaskBot], workingArrays.badBots)
//      }
//      else {
//        return (workingArrays.goodBots, workingArrays.badBots + [thisTaskBot])
//      }
//
//    }
//
//    let badBotPercentage = Float(badTaskBots.count) / Float(goodTaskBots.count + badTaskBots.count)
//
//    // Create and store an entity snapshot in the `entitySnapshots` dictionary for each entity.
//    for entity in scene.entities {
//      let entitySnapshot = EntitySnapshot(badBotPercentage: badBotPercentage, proximityFactor: scene.levelConfiguration.proximityFactor, entityDistances: entityDistances[entity]!)
//      entitySnapshots[entity] = entitySnapshot
//    }
//
//  }
//
//}
//
//class EntitySnapshot {
//  // MARK: - Properties
//
//  /// Percentage of `TaskBot`s in the level that are bad.
//  let badBotPercentage: Float
//
//  /// The factor used to normalize distances between characters for 'fuzzy' logic.
//  let proximityFactor: Float
//
//  /// Distance to the `PlayerBot` if it is targetable.
//  let playerBotTarget: (target: Amber, distance: Float)?
//
//  /// The nearest "good" `TaskBot`.
//  let nearestGoodTaskBotTarget: (target: Enemy, distance: Float)?
//
//  /// A sorted array of distances from this entity to every other entity in the level.
//  let entityDistances: [EntityDistance]
//
//  // MARK: Initialization
//
//  init(badBotPercentage: Float, proximityFactor: Float, entityDistances: [EntityDistance]) {
//    self.badBotPercentage = badBotPercentage
//    self.proximityFactor = proximityFactor
//
//    // Sort the `entityDistances` array by distance (nearest first), and store the sorted version.
//    self.entityDistances = entityDistances.sorted {
//      return $0.distance < $1.distance
//    }
//
//    var playerBotTarget: (target: Amber, distance: Float)?
//    var nearestGoodTaskBotTarget: (target: Enemy, distance: Float)?
//
//    /*
//     Iterate over the sorted `entityDistances` array to find the `PlayerBot`
//     (if it is targetable) and the nearest "good" `TaskBot`.
//     */
//    for entityDistance in self.entityDistances {
//      if let target = entityDistance.target as? Amber, playerBotTarget == nil && target.isTargetable {
//        playerBotTarget = (target: target, distance: entityDistance.distance)
//      }
//      else if let target = entityDistance.target as? Enemy, nearestGoodTaskBotTarget == nil && target.isGood {
//        nearestGoodTaskBotTarget = (target: target, distance: entityDistance.distance)
//      }
//
//      // Stop iterating over the array once we have found both the `PlayerBot` and the nearest good `TaskBot`.
//      if playerBotTarget != nil && nearestGoodTaskBotTarget != nil {
//        break
//      }
//    }
//
//    self.playerBotTarget = playerBotTarget
//    self.nearestGoodTaskBotTarget = nearestGoodTaskBotTarget
//  }
//}
