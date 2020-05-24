import Foundation
import SpriteKit
import GameplayKit

class EntityManager {
  let scene: SKScene
  var entities = Set<GKEntity>()
  var toRemove = Set<GKEntity>()
  
  var obstacles = [GKObstacle]()
  
  
  lazy var componentSystems: [GKComponentSystem] = {
    let moveSystem = GKComponentSystem(componentClass: MovementComponent.self)
    let flySystem = GKComponentSystem(componentClass: FlyComponent.self)
    let animationSystem = GKComponentSystem(componentClass: AnimationComponent.self)
    let parallaxSystem = GKComponentSystem(componentClass: ParallaxComponent.self)
    return [moveSystem, flySystem, animationSystem, parallaxSystem]
  }()
  
  init(scene: SKScene, obstacles: [GKObstacle]) {
    self.scene = scene
    self.obstacles = obstacles
  }
  
  func getAmberEntity() -> GKEntity? {
    for entity in entities {
      if let _ = entity.component(ofType: PlayerControlComponent.self) {
        return entity
      }
    }
    return nil
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
  
  func add(_ entity: GKEntity) {
    entities.insert(entity)
    
    if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node {
      scene.addChild(spriteNode)
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
