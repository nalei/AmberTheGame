import Foundation
import SpriteKit
import GameplayKit

class EntityManager {
  // MARK: - Properties
  
  let scene: LevelScene
  var entities = Set<GKEntity>()
  var character: Amber?
  var toRemove = Set<GKEntity>()
  var levelStateSnapshot: LevelStateSnapshot?
  
  lazy var componentSystems: [GKComponentSystem] = {
    let moveSystem = GKComponentSystem(componentClass: MovementComponent.self)
    let agentSystem = GKComponentSystem(componentClass: AgentComponent.self)
    let animationSystem = GKComponentSystem(componentClass: AnimationComponent.self)
    let parallaxSystem = GKComponentSystem(componentClass: ParallaxComponent.self)
    let attackSystem = GKComponentSystem(componentClass: AttackComponent.self)
    let rulesSystem = GKComponentSystem(componentClass: RulesComponent.self)
    let intelligenceSystem = GKComponentSystem(componentClass: IntelligenceComponent.self)
    return [moveSystem, agentSystem, animationSystem, parallaxSystem, attackSystem, rulesSystem, intelligenceSystem]
  }()
  
  
  // MARK: - Initialization
  
  init(scene: LevelScene) {
    self.scene = scene
  }
  
  
  // MARK: - Convenience
  
  /// Возвращает `GKAgent2D` игрока
  func getAmberAgent() -> GKAgent2D? {
    return scene.character?.agent
  }
  
  /// Возвращает массив всех `AgentComponent`
  func getAllAgents() -> [AgentComponent] {
    var agentComponents = [AgentComponent]()
    for entity in entities {
      if let agentComponent = entity.component(ofType: AgentComponent.self) {
        agentComponents.append(agentComponent)
      }
    }
    return agentComponents
  }
  
  // MARK: Rule State
  
  /// Возвращает снимок состояния,  для переданного объекта, в последствии этот снимок используется для "Fuzzy rules".
  func entitySnapshotForEntity(entity: GKEntity) -> EntitySnapshot? {
    
    if levelStateSnapshot == nil {
      levelStateSnapshot = LevelStateSnapshot(scene: self.scene)
    }
    
    return levelStateSnapshot!.entitySnapshots[entity]
  }
  
  func add(_ entity: GKEntity) {
    entities.insert(entity)
    
    if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node {
      scene.addChild(spriteNode)
    }
    
    if let amber = entity as? Amber {
      self.character = amber
      scene.graphLayer.addChild(amber.debugNode)
    }
    
    if let enemy = entity as? Enemy {
      scene.graphLayer.addChild(enemy.debugNode)
    }
    
    for componentSystem in componentSystems {
      componentSystem.addComponent(foundIn: entity)
    }
  }
  
  func remove(_ entity: GKEntity) {
    if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node {
      spriteNode.removeFromParent()
    }
    
    entities.remove(entity)
    toRemove.insert(entity)
  }
  
  func update(deltaTime: CFTimeInterval) {
    for componentSystem in componentSystems {
      componentSystem.update(deltaTime: deltaTime)
    }
    
    for currentRemove in toRemove {
      for componentSystem in componentSystems {
        componentSystem.removeComponent(foundIn: currentRemove)
      }
    }
    toRemove.removeAll()
    
    // Избавляемся от устаревшего `LevelStateSnapshot`. Он будет сгенерирован при следующей необходимости.
    levelStateSnapshot = nil
  }
}
