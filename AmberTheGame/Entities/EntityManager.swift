import Foundation
import SpriteKit
import GameplayKit

class EntityManager {
  let scene: SKScene
  var entities = Set<GKEntity>()
  var toRemove = Set<GKEntity>()
  
  lazy var componentSystems: [GKComponentSystem] = {
    let playerControlSystem = GKComponentSystem(componentClass: PlayerControlComponent.self)
    let moveSystem = GKComponentSystem(componentClass: EnemyMoveComponent.self)
    return [moveSystem, playerControlSystem]
  }()
  
  init(scene: SKScene) {
    self.scene = scene
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
