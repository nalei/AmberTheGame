import Foundation
import SpriteKit
import GameplayKit

class EntityManager {
  let scene: LevelScene
  var entities = Set<GKEntity>()
  var toRemove = Set<GKEntity>()
  
  lazy var componentSystems: [GKComponentSystem] = {
    let moveSystem = GKComponentSystem(componentClass: MovementComponent.self)
    let flySystem = GKComponentSystem(componentClass: FlyComponent.self)
    let agentSystem = GKComponentSystem(componentClass: AgentComponent.self)
    let animationSystem = GKComponentSystem(componentClass: AnimationComponent.self)
    let parallaxSystem = GKComponentSystem(componentClass: ParallaxComponent.self)
    return [moveSystem, flySystem, agentSystem, animationSystem, parallaxSystem]
  }()
  
  init(scene: LevelScene) {
    self.scene = scene
  }
  
  /// Возвращает массив всех `FlyComponent`
  func getAllFlyComponents() -> [FlyComponent] {
    var flyComponents = [FlyComponent]()
    for entity in entities {
      if let flyComponent = entity.component(ofType: FlyComponent.self) {
        flyComponents.append(flyComponent)
      }
    }
    return flyComponents
  }
  
  /// Возвращает `GKAgent2D` игрока
  func getAmberAgent() -> GKAgent2D? {
    return scene.character?.agent
  }
  
  /// Возвращает массив всех `AgentComponent`
  func getAllAgentComponents() -> [GKAgent2D] {
    var agentComponents = [AgentComponent]()
    for entity in entities {
      if let agentComponent = entity.component(ofType: AgentComponent.self) {
        agentComponents.append(agentComponent)
      }
    }
    return agentComponents
  }
  
  func add(_ entity: GKEntity) {
    entities.insert(entity)
    
    if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node {
      scene.addChild(spriteNode)
    }
    
    if let debugNode = entity.component(ofType: FlyComponent.self)?.debugNode {
      scene.addChild(debugNode)
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
  }
}
